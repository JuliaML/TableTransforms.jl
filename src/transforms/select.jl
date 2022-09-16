# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

struct TableSelection{T,C} 
  table::T
  cols::C
  names::Vector{Symbol}
  onames::Vector{Symbol}
  mapnames::Dict{Symbol,Symbol}
  function TableSelection(table::T, names, onames) where {T}
    cols = Tables.columns(table)
    @assert onames ⊆ Tables.columnnames(cols)
    new{T,typeof(cols)}(table, cols, names, onames, Dict(zip(names, onames)))
  end
end

function Base.:(==)(a::TableSelection, b::TableSelection)
  a.names  != b.names  && return false
  a.onames != b.onames && return false
  all(Tables.getcolumn(a, nm) == Tables.getcolumn(b, nm) for nm in a.names)
end

function Base.show(io::IO, t::TableSelection)
  println(io, "TableSelection")
  pretty_table(io, t, vcrop_mode=:middle, newline_at_end=false)
end

# Tables.jl interface
Tables.istable(::Type{<:TableSelection}) = true
Tables.columnaccess(::Type{<:TableSelection}) = true
Tables.columns(t::TableSelection) = t
Tables.columnnames(t::TableSelection) = t.names
Tables.getcolumn(t::TableSelection, i::Int) =
  Tables.getcolumn(t.cols, t.names[i])
function Tables.getcolumn(t::TableSelection, nm::Symbol)
  nm ∉ t.names && error("Table has no column $nm.")
  Tables.getcolumn(t.cols, t.mapnames[nm])
end

function Tables.schema(t::TableSelection)
  schema = Tables.schema(t.table)
  names = schema.names
  types = schema.types
  inds = indexin(t.onames, collect(names))
  Tables.Schema(t.names, types[inds])
end

Tables.materializer(t::TableSelection) = 
  Tables.materializer(t.table)

"""
    Select(col₁, col₂, ..., colₙ)
    Select([col₁, col₂, ..., colₙ])
    Select((col₁, col₂, ..., colₙ))
    
The transform that selects columns `col₁`, `col₂`, ..., `colₙ`.

    Select(col₁ => newcol₁, col₂ => newcol₂, ..., colₙ => newcolₙ)

Selects the columns `col₁`, `col₂`, ..., `colₙ`
and rename them to `newcol₁`, `newcol₂`, ..., `newcolₙ`.
    
    Select(regex)

Selects the columns that match with `regex`.

# Examples

```julia
Select(1, 3, 5)
Select([:a, :c, :e])
Select(("a", "c", "e"))
Select(1 => :x, 3 => :y)
Select(:a => :x, :b => :y)
Select("a" => "x", "b" => "y")
Select(r"[ace]")
```
"""
struct Select{S<:ColSpec} <: Stateless
  colspec::S
  newnames::Union{Vector{Symbol},Nothing}
end

Select(spec) = Select(colspec(spec), nothing)
Select(cols::T...) where {T<:Col} = Select(cols)

Select(pairs::Pair{T,Symbol}...) where {T<:Col} = 
  Select(colspec(first.(pairs)), collect(last.(pairs)))

Select(pairs::Pair{T,S}...) where {T<:Col,S<:AbstractString} = 
  Select(colspec(first.(pairs)), collect(Symbol.(last.(pairs))))

Select() = throw(ArgumentError("Cannot create a Select object without arguments."))

isrevertible(::Type{<:Select}) = true

# utils
_newnames(::Nothing, select) = select
_newnames(names::Vector{Symbol}, select) = names

function apply(transform::Select, table)
  # original columns
  cols = Tables.columns(table)

  # retrieve relevant column names
  allcols = collect(Tables.columnnames(cols))
  select  = choose(transform.colspec, allcols)
  names   = _newnames(transform.newnames, select)
  reject  = setdiff(allcols, select)

  # keep track of indices to revert later
  sinds = indexin(select, allcols)
  rinds = indexin(reject, allcols)

  # sort indices to facilitate reinsertion
  sperm = sortperm(sinds)

  # rejected columns
  rcolumns = [Tables.getcolumn(cols, name) for name in reject]

  TableSelection(table, names, select), (select, sperm, reject, rcolumns, rinds)
end

function revert(::Select, newtable, cache)
  # selected columns
  cols  = Tables.columns(newtable)
  names = Tables.columnnames(cols)
  # https://github.com/JuliaML/TableTransforms.jl/issues/76
  columns = Any[Tables.getcolumn(cols, name) for name in names]

  # rejected columns
  select, sperm, reject, rcolumns, rinds = cache

  # restore rejected columns
  onames = select[sperm]
  ocolumns = columns[sperm]
  for (i, rind) in enumerate(rinds)
    insert!(onames, rind, reject[i])
    insert!(ocolumns, rind, rcolumns[i])
  end

  𝒯 = (; zip(onames, ocolumns)...)
  𝒯 |> Tables.materializer(newtable)
end

# reverting a single TableSelection is trivial
revert(::Select, newtable::TableSelection, cache) = newtable.table

"""
    Reject(col₁, col₂, ..., colₙ)
    Reject([col₁, col₂, ..., colₙ])
    Reject((col₁, col₂, ..., colₙ))

The transform that discards columns `col₁`, `col₂`, ..., `colₙ`.

    Reject(regex)

Discards the columns that match with `regex`.

# Examples

```julia
Reject(:b, :d, :f)
Reject(["b", "d", "f"])
Reject((2, 4, 6))
Reject(r"[bdf]")
```
"""
struct Reject{S<:ColSpec} <: Stateless
  colspec::S
end

Reject(spec) = Reject(colspec(spec))

Reject(cols::T...) where {T<:Col} = 
  Reject(colspec(cols))

# argumet erros
Reject() = throw(ArgumentError("Cannot create a Reject object without arguments."))
Reject(::AllSpec) = throw(ArgumentError("Cannot reject all columns."))

isrevertible(::Type{<:Reject}) = true

function apply(transform::Reject, table)
  cols = Tables.columns(table)
  allcols = Tables.columnnames(cols)
  reject  = choose(transform.colspec, allcols)
  select  = setdiff(allcols, reject)
  strans  = Select(select)
  newtable, scache = apply(strans, table)
  newtable, (strans, scache)
end

function revert(::Reject, newtable, cache)
  strans, scache = cache
  revert(strans, newtable, scache)
end

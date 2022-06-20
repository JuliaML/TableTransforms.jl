# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

struct TableSelection{T,C} 
  table::T
  cols::C
  names::Vector{Symbol}
  function TableSelection(table::T, names::Vector{Symbol}) where {T}
    cols = Tables.columns(table)
    @assert names ⊆ Tables.columnnames(cols)
    new{T,typeof(cols)}(table, cols, names)
  end
end

function Base.:(==)(a::TableSelection, b::TableSelection)
  a.names != b.names && return false
  all(Tables.getcolumn(a, nm) == Tables.getcolumn(b, nm) for nm in a.names)
end

function Base.show(io::IO, t::TableSelection)
  println(io, "TableSelection")
  pretty_table(io, t, vcrop_mode=:middle)
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
  Tables.getcolumn(t.cols, nm)
end

function Tables.schema(t::TableSelection)
  schema = Tables.schema(t.table)
  names = schema.names
  types = schema.types
  inds = indexin(t.names, collect(names))
  Tables.Schema(t.names, types[inds])
end

Tables.materializer(t::TableSelection) = 
  Tables.materializer(t.table)

"""
    Select(col₁, col₂, ..., colₙ)
    Select([col₁, col₂, ..., colₙ])
    Select((col₁, col₂, ..., colₙ))
    
The transform that selects columns `col₁`, `col₂`, ..., `colₙ`.
    
    Select(regex)

Selects the columns that match with `regex`.

# Examples

```julia
Select(1, 3, 5)
Select([:a, :c, :e])
Select(("a", "c", "e"))
Select(r"[ace]")
```
"""
struct Select{S<:ColSpec} <: Stateless
  colspec::S
end

Select(spec) = Select(ascolspec(spec))

Select(cols::T...) where {T<:Col} = 
  Select(ascolspec(cols))

Select() = throw(ArgumentError("Cannot create a Select object without arguments."))

isrevertible(::Type{<:Select}) = true

function apply(transform::Select, table)
  # original columns
  cols = Tables.columns(table)

  # retrieve relevant column names
  allcols = collect(Tables.columnnames(cols))
  select  = choose(transform.colspec, allcols)
  reject  = setdiff(allcols, select)

  # keep track of indices to revert later
  sinds = indexin(select, allcols)
  rinds = indexin(reject, allcols)

  # sort indices to facilitate reinsertion
  sperm  = sortperm(sinds)
  sorted = sortperm(rinds)
  reject = reject[sorted]
  rinds  = rinds[sorted]

  # rejected columns
  rcols = [Tables.getcolumn(cols, name) for name in reject]

  TableSelection(table, select), (reject, rcols, sperm, rinds)
end

function revert(::Select, newtable, cache)
  # selected columns
  cols   = Tables.columns(newtable)
  select = Tables.columnnames(cols)
  # https://github.com/JuliaML/TableTransforms.jl/issues/76
  scols  = Any[Tables.getcolumn(cols, name) for name in select]

  # rejected columns
  reject, rcols, sperm, rinds = cache

  # restore rejected columns
  anames = collect(select[sperm])
  acols  = collect(scols[sperm])
  for (i, rind) in enumerate(rinds)
    insert!(anames, rind, reject[i])
    insert!(acols, rind, rcols[i])
  end
  𝒯 = (; zip(anames, acols)...)
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

Reject(spec) = Reject(ascolspec(spec))

Reject(cols::T...) where {T<:Col} = 
  Reject(ascolspec(cols))

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

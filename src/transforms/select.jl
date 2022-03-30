# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

struct TableSelection{T} 
  table::T
  cols::Vector{Symbol}
  function TableSelection(table::T, cols::Vector{Symbol}) where {T}
    @assert cols ⊆ Tables.columnnames(table)
    new{T}(table, cols)
  end
end

function Base.:(==)(a::TableSelection, b::TableSelection)
  a.cols != b.cols && return false
  all(Tables.getcolumn(a, col) == Tables.getcolumn(b, col) for col in a.cols)
end

function Base.show(io::IO, t::TableSelection)
  println(io, "TableSelection")
  pretty_table(io, t, vcrop_mode=:middle)
end

# Tables.jl interface
Tables.istable(::Type{<:TableSelection}) = true
Tables.columnaccess(::Type{<:TableSelection}) = true
Tables.columns(t::TableSelection) = t
Tables.columnnames(t::TableSelection) = t.cols
Tables.getcolumn(t::TableSelection, col::Int) =
  Tables.getcolumn(t.table, t.cols[col])
Tables.getcolumn(t::TableSelection, col::Symbol) = 
  Tables.getcolumn(t.table, col)

function Tables.schema(t::TableSelection)
  schema = Tables.schema(t.table)
  names = schema.names
  types = schema.types
  inds = indexin(t.cols, collect(names))
  Tables.Schema(t.cols, types[inds])
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
"""
struct Select{S<:ColSpec} <: Stateless
  colspec::S
end

# argument errors
Select(::Tuple{}) = throw(ArgumentError("Cannot create a Select object with empty tuple."))
Select() = throw(ArgumentError("Cannot create a Select object without arguments."))

Select(cols::T...) where {T<:ColSelector} = 
  Select(cols)

isrevertible(::Type{<:Select}) = true

function apply(transform::Select, table)
  # retrieve relevant column names
  allcols = collect(Tables.columnnames(table))
  select  = _filter(transform.colspec, allcols)
  reject  = setdiff(allcols, select)

  # validate selections
  @assert !isempty(select) "Invalid selection"
  @assert select ⊆ Tables.columnnames(table) "Invalid selection"

  # keep track of indices to revert later
  sinds = indexin(select, allcols)
  rinds = indexin(reject, allcols)

  # sort indices to facilitate reinsertion
  sperm  = sortperm(sinds)
  sorted = sortperm(rinds)
  reject = reject[sorted]
  rinds  = rinds[sorted]

  # original columns
  cols = Tables.columns(table)

  # rejected columns
  rcols = [Tables.getcolumn(cols, name) for name in reject]

  TableSelection(table, select), (reject, rcols, sperm, rinds)
end

function revert(::Select, newtable, cache)
  # selected columns
  cols   = Tables.columns(newtable)
  select = Tables.columnnames(newtable)
  scols  = [Tables.getcolumn(cols, name) for name in select]

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
"""
struct Reject{S<:ColSpec} <: Stateless
  colspec::S
end

# argumet erros
Reject(::Tuple{}) = throw(ArgumentError("Cannot create a Reject object with empty tuple."))
Reject(::Colon) = throw(ArgumentError("Is no possible reject all colls."))
Reject() = throw(ArgumentError("Cannot create a Reject object without arguments."))

Reject(cols::T...) where {T<:ColSelector} = 
  Reject(cols)

isrevertible(::Type{<:Reject}) = true

function apply(transform::Reject, table)
  allcols = Tables.columnnames(table)
  reject  = _filter(transform.colspec, allcols)
  select  = setdiff(allcols, reject)
  strans  = Select(select)
  newtable, scache = apply(strans, table)
  newtable, (strans, scache)
end

function revert(::Reject, newtable, cache)
  strans, scache = cache
  revert(strans, newtable, scache)
end

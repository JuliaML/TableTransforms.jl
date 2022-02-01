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

function Base.show(io::IO, ts::TableSelection)
  println(io, "TableSelection")
  pretty_table(io, ts, vcrop_mode=:middle)
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

const ColSpec = Union{Vector{Symbol}, Regex}

"""
    Select(col₁, col₂, ..., colₙ)
    Select([col₁, col₂, ..., colₙ])
    Select((col₁, col₂, ..., colₙ))
    
The transform that selects columns `col₁`, `col₂`, ..., `colₙ`.
    
    Select(regex)

Selects the columns that match with `regex`.
"""
struct Select{S<:ColSpec} <: Stateless
  cols::S
end

Select(cols::T...) where {T<:Union{AbstractString, Symbol}} = 
  Select(cols)

Select(cols::NTuple{N, T}) where {N, T<:Union{AbstractString, Symbol}} =
  Select(collect(cols))

Select(cols::Vector{T}) where {T<:AbstractString} =
  Select(Symbol.(cols))

Base.:(==)(a::Select, b::Select) = a.cols == b.cols

isrevertible(::Type{<:Select}) = true

_select(cols::Vector{Symbol}, allcols) = cols
_select(cols::Regex, allcols) = 
  filter(col -> occursin(cols, String(col)), allcols)

function apply(transform::Select, table)
  # retrieve relevant column names
  allcols = collect(Tables.columnnames(table))
  select  = _select(transform.cols, allcols)
  reject  = setdiff(allcols, select)

  @assert select ⊆ Tables.columnnames(table)

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

revert(::Select, newtable::TableSelection, cache) = newtable.table

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

"""
    Reject(col₁, col₂, ..., colₙ)
    Reject([col₁, col₂, ..., colₙ])
    Reject((col₁, col₂, ..., colₙ))

The transform that discards columns `col₁`, `col₂`, ..., `colₙ`.

    Reject(regex)

Discards the columns that match with `regex`.
"""
struct Reject{S<:ColSpec} <: Stateless
  cols::S
end

Reject(cols::T...) where {T<:Union{AbstractString, Symbol}} = 
  Reject(cols)

Reject(cols::NTuple{N, T}) where {N, T<:Union{AbstractString, Symbol}} =
  Reject(collect(cols))

Reject(cols::Vector{T}) where {T<:AbstractString} =
  Reject(Symbol.(cols))

Base.:(==)(a::Reject, b::Reject) = a.cols == b.cols

isrevertible(::Type{<:Reject}) = true

function apply(transform::Reject, table)
  allcols = Tables.columnnames(table)
  reject  = _select(transform.cols, allcols)
  select  = setdiff(allcols, reject)
  strans  = Select(select)
  newtable, scache = apply(strans, table)
  newtable, (strans, scache)
end

function revert(::Reject, newtable, cache)
  strans, scache = cache
  revert(strans, newtable, scache)
end

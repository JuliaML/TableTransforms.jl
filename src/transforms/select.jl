# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

const ColSelector = Union{Vector{Symbol}, Regex}

"""
    Select(col₁, col₂, ..., colₙ)
    Select([col₁, col₂, ..., colₙ])
    Select((col₁, col₂, ..., colₙ))
    
The transform that selects columns `col₁`, `col₂`, ..., `colₙ`.
    
    Select(Regex)
Selects the columns that match with Regex.
"""
struct Select{S<:ColSelector} <: Stateless
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

_selectedcols(cols::Vector{Symbol}, allcols) = cols
_selectedcols(cols::Regex, allcols) = 
  filter(col -> occursin(cols, String(col)), allcols)

function apply(transform::Select, table)
  # retrieve relevant column names
  allcols = collect(Tables.columnnames(table))
  select  = _selectedcols(transform.cols, allcols)
  reject  = setdiff(allcols, select)

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

  # selected columns
  scols = [Tables.getcolumn(cols, name) for name in select]

  # rejected columns
  rcols = [Tables.getcolumn(cols, name) for name in reject]

  # table with selected columns
  𝒯 = (; zip(select, scols)...)
  stable = 𝒯 |> Tables.materializer(table)

  stable, (reject, rcols, sperm, rinds)
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

"""
    Reject(col₁, col₂, ..., colₙ)
    Reject([col₁, col₂, ..., colₙ])
    Reject((col₁, col₂, ..., colₙ))

The transform that discards columns `col₁`, `col₂`, ..., `colₙ`.

    Reject(Regex)
Discards the columns that match with Regex.
"""
struct Reject{S<:ColSelector} <: Stateless
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
  reject  = _selectedcols(transform.cols, allcols)
  select  = setdiff(allcols, reject)
  strans  = Select(select)
  newtable, scache = apply(strans, table)
  newtable, (strans, scache)
end

function revert(::Reject, newtable, cache)
  strans, scache = cache
  revert(strans, newtable, scache)
end

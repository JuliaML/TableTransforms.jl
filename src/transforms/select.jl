# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Select(col₁, col₂, ..., colₙ)
    Select([col₁, col₂, ..., colₙ])

The transform that selects columns `col₁`, `col₂`, ..., `colₙ`.
"""
struct Select{N} <: Stateless
  cols::NTuple{N,Symbol}
end

Select(cols::NTuple{N,AbstractString}) where {N} =
  Select(Symbol.(cols))

Select(cols...) = Select(cols)

isrevertible(::Type{<:Select}) = true

function apply(transform::Select, table)
  # retrieve relevant column names
  allcols = collect(Tables.columnnames(table))
  select  = collect(transform.cols)
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

The transform that discards columns `col₁`, `col₂`, ..., `colₙ`.
"""
struct Reject{N} <: Stateless
  cols::NTuple{N,Symbol}
end

Reject(cols::NTuple{N,AbstractString}) where {N} =
  Reject(Symbol.(cols))

Reject(cols...) = Reject(cols)

isrevertible(::Type{<:Reject}) = true

function apply(transform::Reject, table)
  allcols = Tables.columnnames(table)
  reject  = collect(transform.cols)
  select  = Tuple(setdiff(allcols, reject))
  strans  = Select(select)
  newtable, scache = apply(strans, table)
  newtable, (strans, scache)
end

function revert(::Reject, newtable, cache)
  strans, scache = cache
  revert(strans, newtable, scache)
end
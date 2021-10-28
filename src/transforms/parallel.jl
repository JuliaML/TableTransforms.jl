# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Parallel(transforms)

A transform where `transforms` are applied in parallel.
"""
struct Parallel <: Transform
  transforms::Vector{Transform}
end

isrevertible(p::Parallel) = any(isrevertible, p.transforms)

function apply(p::Parallel, table)
  # apply transforms in parallel
  f(transform) = apply(transform, table)
  result = map(f, p.transforms)

  # retrieve tables and caches
  tables = first.(result)
  caches = last.(result)

  # concatenate columns
  allvars, allvals = [], []
  varsdict = Set{Symbol}()
  for 𝒯 in tables
    cols = Tables.columns(𝒯)
    vars = Tables.columnnames(𝒯)
    vals = [Tables.getcolumn(cols, var) for var in vars]
    for (var, val) in zip(vars, vals)
      while var ∈ varsdict
        var = Symbol(var,:_)
      end
      push!(varsdict, var)
      push!(allvars, var)
      push!(allvals, val)
    end
  end

  # table with concatenated columns
  𝒯 = (; zip(allvars, allvals)...)
  newtable = 𝒯 |> Tables.materializer(table)

  # find first revertible transform
  ind = findfirst(isrevertible, p.transforms)

  # save cache if any transform is revertible
  if isnothing(ind)
    cache = nothing
  else
    onames = Tables.columnnames(table)
    tnames = Tables.columnnames.(tables)
    ncols  = length.(tnames)
    rcache = caches[ind]
    nrcols = ncols[ind]
    start  = sum(ncols[1:ind-1]) + 1
    finish = start + nrcols - 1
    range  = (start, finish)
    cache  = (ind, range, rcache, onames)
  end

  newtable, cache
end

function revert(p::Parallel, newtable, cache)
  @assert !isnothing(cache) "transform is not revertible"

  # retrieve subtable range and cache
  ind    = cache[1]
  range  = cache[2]
  rcache = cache[3]
  onames = cache[4]
  start, finish = range

  # columns of transformed table
  cols  = Tables.columns(newtable)
  names = Tables.columnnames(newtable)

  # retrieve first subtable
  rcols = [Tables.getcolumn(cols, j) for j in start:finish]
  𝒯 = (; zip(onames, rcols)...)
  rtable = 𝒯 |> Tables.materializer(newtable)

  # revert transform on subtable
  rtransform = p.transforms[ind]
  revert(rtransform, rtable, rcache)
end

"""
    transform₁ ∥ transform₂ ∥ ⋯ ∥ transformₙ

Create a [`Parallel`](@ref) transform with
`[transform₁, transform₂, …, transformₙ]`.
"""
∥(t1, t2) = Parallel([t1, t2])
∥(t1, t2::Parallel) = Parallel([t1; t2.transforms])
∥(t1::Parallel, t2) = Parallel([t1.transforms; t2])
∥(t1::Parallel, t2::Parallel) = Parallel([t1.transforms; t2.transforms])
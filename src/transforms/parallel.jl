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
  vals = tcollect(f(t) for t in p.transforms)

  # retrieve tables and caches
  tables = first.(vals)
  caches = last.(vals)

  # table with concatenated columns
  newtable = tablehcat(tables)

  # save original column names
  onames = Tables.columnnames(table)

  # find first revertible transform
  ind = findfirst(isrevertible, p.transforms)

  # save info to revert transform
  rinfo = if isnothing(ind)
    nothing
  else
    tnames = Tables.columnnames.(tables)
    ncols  = length.(tnames)
    nrcols = ncols[ind]
    start  = sum(ncols[1:ind-1]) + 1
    finish = start + nrcols - 1
    range  = start:finish
    (ind, range)
  end

  newtable, (onames, caches, rinfo)
end

function revert(p::Parallel, newtable, cache)
  # retrieve cache
  onames = cache[1]
  caches = cache[2]
  rinfo  = cache[3]

  @assert !isnothing(rinfo) "transform is not revertible"

  # retrieve info to revert transform
  ind    = rinfo[1]
  range  = rinfo[2]
  rtrans = p.transforms[ind]
  rcache = caches[ind]

  # columns of transformed table
  cols = Tables.columns(newtable)

  # retrieve subtable to revert
  rcols = [Tables.getcolumn(cols, j) for j in range]
  𝒯 = (; zip(onames, rcols)...)
  rtable = 𝒯 |> Tables.materializer(newtable)

  # revert transform on subtable
  revert(rtrans, rtable, rcache)
end

function reapply(p::Parallel, table, cache)
  # retrieve caches
  caches = cache[2]

  # reapply transforms in parallel
  f(t, c)  = reapply(t, table, c) |> first
  itr      = zip(p.transforms, caches)
  tables   = tcollect(f(t, c) for (t, c) in itr)

  # table with concatenated columns
  newtable = tablehcat(tables)

  newtable, cache
end

function tablehcat(tables)
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
  𝒯 |> Tables.materializer(first(tables))
end

"""
    transform₁ ⊔ transform₂ ⊔ ⋯ ⊔ transformₙ

Create a [`Parallel`](@ref) transform with
`[transform₁, transform₂, …, transformₙ]`.
"""
⊔(t1::Transform, t2::Transform) = Parallel([t1, t2])
⊔(t1::Transform, t2::Parallel)  = Parallel([t1; t2.transforms])
⊔(t1::Parallel, t2::Transform)  = Parallel([t1.transforms; t2])
⊔(t1::Parallel, t2::Parallel)   = Parallel([t1.transforms; t2.transforms])
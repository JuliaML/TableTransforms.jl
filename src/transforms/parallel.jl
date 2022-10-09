# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    ParallelTableTransform(transforms)

A transform where `transforms` are applied in parallel.

# Examples

```julia
Scale(low=0.3, high=0.6) ⊔ EigenAnalysis(:VDV)
ZScore() ⊔ EigenAnalysis(:V)
```
"""
struct ParallelTableTransform <: TableTransform
  transforms::Vector{Transform}
end

# AbstractTrees interface
AbstractTrees.nodevalue(::ParallelTableTransform) = ParallelTableTransform
AbstractTrees.children(p::ParallelTableTransform) = p.transforms

Base.show(io::IO, p::ParallelTableTransform) =
  print(io, join(p.transforms, " ⊔ "))

function Base.show(io::IO, ::MIME"text/plain", p::ParallelTableTransform)
  tree = repr_tree(p, context=io)
  print(io, tree[begin:end-1]) # remove \n at end
end

isrevertible(p::ParallelTableTransform) = any(isrevertible, p.transforms)

function apply(p::ParallelTableTransform, table)
  # apply transforms in parallel
  f(transform) = apply(transform, table)
  vals = tcollect(f(t) for t in p.transforms)

  # retrieve tables and caches
  tables = first.(vals)
  caches = last.(vals)

  # features and metadata
  splits = divide.(tables)
  feats  = first.(splits)
  metas  = last.(splits)

  # table with concatenated features
  newfeat = tablehcat(feats)

  # propagate metadata
  newmeta = first(metas)

  # attach new features and metatada
  newtable = attach(newfeat, newmeta)

  # find first revertible transform
  ind = findfirst(isrevertible, p.transforms)

  # save info to revert transform
  rinfo = if isnothing(ind)
    nothing
  else
    fcols  = Tables.columns.(feats)
    fnames = Tables.columnnames.(fcols)
    ncols  = length.(fnames)
    nrcols = ncols[ind]
    start  = sum(ncols[1:ind-1]) + 1
    finish = start + nrcols - 1
    range  = start:finish
    (ind, range)
  end

  newtable, (caches, rinfo)
end

function revert(p::ParallelTableTransform, newtable, cache)
  # retrieve cache
  caches = cache[1]
  rinfo  = cache[2]

  @assert !isnothing(rinfo) "transform is not revertible"

  # features and metadata
  newfeat, newmeta = divide(newtable)

  # retrieve info to revert transform
  ind    = rinfo[1]
  range  = rinfo[2]
  rtrans = p.transforms[ind]
  rcache = caches[ind]

  # columns of transformed table
  fcols = Tables.columns(newfeat)
  names = Tables.columnnames(fcols)

  # subset of features to revert
  rnames = names[range]
  rcols  = [Tables.getcolumn(fcols, j) for j in range]
  rfeat  = (; zip(rnames, rcols)...) |> Tables.materializer(newfeat)

  # propagate metadata
  rtable = attach(rfeat, newmeta)

  # revert transform
  revert(rtrans, rtable, rcache)
end

function reapply(p::ParallelTableTransform, table, cache)
  # retrieve caches
  caches = cache[1]

  # reapply transforms in parallel
  f(t, c) = reapply(t, table, c)
  itr     = zip(p.transforms, caches)
  tables  = tcollect(f(t, c) for (t, c) in itr)

  # features and metadata
  splits = divide.(tables)
  feats  = first.(splits)
  metas  = last.(splits)

  # table with concatenated features
  newfeat = tablehcat(feats)

  # metadata of the first table
  newmeta = first(metas)

  # attach new features and metatada
  attach(newfeat, newmeta)
end

function tablehcat(tables)
  # concatenate columns
  allvars, allvals = [], []
  varsdict = Set{Symbol}()
  for 𝒯 in tables
    cols = Tables.columns(𝒯)
    vars = Tables.columnnames(cols)
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

Create a [`ParallelTableTransform`](@ref) transform with
`[transform₁, transform₂, …, transformₙ]`.
"""
⊔(t1::Transform, t2::Transform) =
  ParallelTableTransform([t1, t2])
⊔(t1::Transform, t2::ParallelTableTransform) =
  ParallelTableTransform([t1; t2.transforms])
⊔(t1::ParallelTableTransform, t2::Transform) =
  ParallelTableTransform([t1.transforms; t2])
⊔(t1::ParallelTableTransform, t2::ParallelTableTransform) =
  ParallelTableTransform([t1.transforms; t2.transforms])

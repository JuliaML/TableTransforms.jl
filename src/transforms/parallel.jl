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

  # number of columns for first subtable
  ftable = tables |> first
  fcache = caches |> first
  nfcols = ftable |> Tables.columnnames |> length

  newtable, (nfcols, fcache)
end

function revert(p::Parallel, newtable, cache)
  # retrieve individual caches
  nfcols = first(cache)
  fcache = last(cache)

  # columns of transformed table
  cols  = Tables.columns(newtable)
  names = Tables.columnnames(newtable)

  # retrieve first subtable
  fcols  = [Tables.getcolumn(cols, j) for j in 1:nfcols]
  fnames = names[1:nfcols]
  𝒯 = (; zip(fnames, fcols)...)
  ftable = 𝒯 |> Tables.materializer(newtable)

  # revert transform on subtable
  ftransform = first(p.transforms)
  revert(ftransform, ftable, fcache)
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
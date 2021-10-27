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

isrevertible(p::Parallel) = all(isrevertible, p.transforms)

function apply(p::Parallel, table)
  # apply transforms in parallel
  result = map(t -> apply(t, table), p.transforms)

  # retrieve tables and caches
  tables = first.(result)
  caches = last.(result)

  # concatenate columns
  varsdict = Set{Symbol}()
  allvars, allvals = [], []
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

  # number of columns for each subtable
  ncols = tables .|> Tables.columnnames .|> length

  newtable, (ncols, caches)
end

function revert(p::Parallel, newtable, cache)
end

"""
    transform₁ ∥ transform₂ ∥ ⋯ ∥ transformₙ

Create a [`Parallel`](@ref) transform with
`[transform₁, transform₂, …, transformₙ]`.
"""
∥(t1, t2) = Parallel([t1, t2])
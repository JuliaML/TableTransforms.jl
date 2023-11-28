# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Sample(size, [weights]; replace=true, ordered=false, rng=GLOBAL_RNG)

Sample `size` rows of table using `weights` with or without replacement depending
on the option `replace`. The option `ordered` can be used to return samples in
the same order of the original table.

# Examples

```julia
Sample(1000)
Sample(1000, replace=false)
Sample(1000, replace=false, ordered=true)

# with rng
using Random
rng = MersenneTwister(2)
Sample(1000, rng=rng)

# with weights
Sample(10, rand(100))
```
"""
struct Sample{W,RNG} <: StatelessFeatureTransform
  size::Int
  weights::W
  replace::Bool
  ordered::Bool
  rng::RNG
end

Sample(size::Int; replace=false, ordered=false, rng=Random.GLOBAL_RNG) = Sample(size, nothing, replace, ordered, rng)

Sample(size::Int, weights::AbstractWeights; replace=false, ordered=false, rng=Random.GLOBAL_RNG) =
  Sample(size, weights, replace, ordered, rng)

Sample(size::Int, weights; kwargs...) = Sample(size, Weights(collect(weights)); kwargs...)

isrevertible(::Type{<:Sample}) = true

function preprocess(transform::Sample, feat)
  # retrieve valid indices
  inds = 1:_nrows(feat)

  size = transform.size
  weights = transform.weights
  replace = transform.replace
  ordered = transform.ordered
  rng = transform.rng

  # sample a subset of indices
  sinds = if isnothing(weights)
    sample(rng, inds, size; replace, ordered)
  else
    sample(rng, inds, weights, size; replace, ordered)
  end
  rinds = setdiff(inds, sinds)

  sinds, rinds
end

function applyfeat(::Sample, feat, prep)
  # preprocessed indices
  sinds, rinds = prep

  # selected and removed rows
  srows = Tables.subset(feat, sinds, viewhint=true)
  rrows = Tables.subset(feat, rinds, viewhint=true)

  newfeat = srows |> Tables.materializer(feat)
  newfeat, (sinds, rinds, rrows)
end

function revertfeat(::Sample, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)
  sinds, rinds, rrows = fcache

  # columns with selected rows in original order
  uinds = indexin(sort(unique(sinds)), sinds)
  columns = map(names) do name
    y = Tables.getcolumn(cols, name)
    [y[i] for i in uinds]
  end

  # insert removed rows into columns
  rrcols = Tables.columns(rrows)
  for (name, x) in zip(names, columns)
    r = Tables.getcolumn(rrcols, name)
    for (i, v) in zip(rinds, r)
      insert!(x, i, v)
    end
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

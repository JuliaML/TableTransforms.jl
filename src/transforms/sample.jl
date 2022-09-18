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
Sample(1_000)
Sample(1_000, replace=false)
Sample(1_000, replace=false, ordered=true)

# with rng
using Random
rng = MersenneTwister(2)
Sample(1_000, rng=rng)

# with weights
Sample(10, rand(100))
```
"""
struct Sample{W,RNG} <: Stateless
  size::Int
  weights::W
  replace::Bool
  ordered::Bool
  rng::RNG
end

Sample(size::Int;
       replace=false, ordered=false,
       rng=Random.GLOBAL_RNG) =
  Sample(size, nothing, replace, ordered, rng)
  
Sample(size::Int, weights::AbstractWeights;
       replace=false, ordered=false,
       rng=Random.GLOBAL_RNG) =
  Sample(size, weights, replace, ordered, rng)
  
Sample(size::Int, weights; kwargs...) =
  Sample(size, Weights(collect(weights)); kwargs...)

isrevertible(::Type{<:Sample}) = true

function preprocess(transform::Sample, table)
  # retrieve valid indices
  rows = Tables.rowtable(table)
  inds = 1:length(rows)

  size    = transform.size
  weights = transform.weights
  replace = transform.replace
  ordered = transform.ordered
  rng     = transform.rng

  # sample a subset of indices
  sinds = if isnothing(weights)
    sample(rng, inds, size; replace, ordered)
  else
    sample(rng, inds, weights, size; replace, ordered)
  end
  rinds = setdiff(inds, sinds)

  sinds, rinds
end

function applyfeat(::Sample, table, prep)
  # collect all rows
  rows = Tables.rowtable(table)

  # preprocessed indices
  sinds, rinds = prep

  # select rows
  srows = view(rows, sinds)
  rrows = view(rows, rinds)

  stable = srows |> Tables.materializer(table)

  stable, (sinds, rinds, rrows)
end

function revertfeat(::Sample, newtable, fcache)
  # collect all rows
  rows = Tables.rowtable(newtable)

  sinds, rinds, rrows = fcache

  uinds = sort(unique(sinds))
  urows = map(uinds) do i
    j = findfirst(==(i), sinds)
    rows[j]
  end

  for (i, row) in zip(rinds, rrows)
    insert!(urows, i, row)
  end

  urows |> Tables.materializer(newtable)
end
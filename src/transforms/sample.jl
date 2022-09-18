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

isrevertible(::Type{<:Sample}) = false

function applyfeat(transform::Sample, table)
  rows = Tables.rowtable(table)

  size    = transform.size
  weights = transform.weights
  replace = transform.replace
  ordered = transform.ordered
  rng     = transform.rng

  newrows = if isnothing(weights)
    sample(rng, rows, size; replace, ordered)
  else
    sample(rng, rows, weights, size; replace, ordered)
  end

  newtable = newrows |> Tables.materializer(table)

  newtable, nothing
end
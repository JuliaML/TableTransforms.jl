# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Sample([rng], [wv::AbstractWeights], n; replace=true, ordered=false)

Sample table rows by forwarding arguments to the `sample` function of StatsBase.jl.
Optionally, a random number generator `rng` and a weight vector `wv` can be used.

# Examples

```julia
Sample(1_000)
Sample(1_000, replace=false)
Sample(1_000, replace=false, ordered=true)

# with rng
using Random
rng = MersenneTwister(2)
Sample(rng, 1_000)

# with wv
using StatsBase
wv = pweights([0.2, 0.1, 0.3])
Sample(wv, 1_000)
Sample(rng, wv, 1_000)
```
"""
struct Sample{R<:AbstractRNG,W} <: Stateless
  rng::R
  wv::W
  n::Int
  replace::Bool
  ordered::Bool
end

Sample(rng::AbstractRNG, wv::AbstractWeights, n::Int; replace=true, ordered=false) =
  Sample(rng, wv, n, replace, ordered)

Sample(rng::AbstractRNG, n::Int; replace=true, ordered=false) =
  Sample(rng, nothing, n, replace, ordered)

Sample(wv::AbstractWeights, n::Int; replace=true, ordered=false) =
  Sample(Random.GLOBAL_RNG, wv, n, replace, ordered)

Sample(n::Int; replace=true, ordered=false) =
  Sample(Random.GLOBAL_RNG, nothing, n, replace, ordered)

isrevertible(::Type{<:Sample}) = false

function apply(transform::Sample, table)
  rows = Tables.rowtable(table)

  rng     = transform.rng
  wv      = transform.wv
  n       = transform.n
  replace = transform.replace
  ordered = transform.ordered

  if isnothing(wv)
    newrows = sample(rng, rows, n; replace, ordered)
  else
    newrows = sample(rng, rows, wv, n; replace, ordered)
  end

  newtable = newrows |> Tables.materializer(table)
  newtable, nothing
end

revert(::Sample, newtable, cache) = 
  throw(AssertionError("Transform is not revertible."))

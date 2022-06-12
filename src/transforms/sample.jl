# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Sample([rng], n; replace=true, ordered=false)

Sample table rows by forwarding arguments to the `sample` function of StatsBase.jl.
Optionally, a specific `rng` random number generator can be used by passing it as the first argument
(default is `Random.GLOBAL_RNG`).

# Examples

```julia
Sample(1_000)
Sample(1_000, replace=false)
Sample(1_000, replace=false, ordered=true)

# with rng
using Random
rng = MersenneTwister(2)
Sample(rng, 1_000)
```
"""
struct Sample{R<:AbstractRNG} <: Stateless
  rng::R
  n::Int
  replace::Bool
  ordered::Bool
end

Sample(rng::AbstractRNG, n::Int; replace=true, ordered=false) =
  Sample(rng, n, replace, ordered)

Sample(n::Int; replace=true, ordered=false) =
  Sample(Random.GLOBAL_RNG, n, replace, ordered)

isrevertible(::Type{<:Sample}) = false

function apply(transform::Sample, table)
  rows = Tables.rowtable(table)

  rng     = transform.rng
  n       = transform.n
  replace = transform.replace
  ordered = transform.ordered

  newrows = sample(rng, rows, n; replace, ordered)

  newtable = newrows |> Tables.materializer(table)
  newtable, nothing
end

revert(::Sample, newtable, cache) = 
  throw(AssertionError("Transform is not revertible."))

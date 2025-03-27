# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    KMedoids(k; tol=1e-4, maxiter=10, weights=nothing, rng=Random.default_rng())

Assign labels to rows of table using the `k`-medoids algorithm.

The iterative algorithm is interrupted if the relative change on
the average distance to medoids is smaller than a tolerance `tol`
or if the number of iterations exceeds the maximum number of
iterations `maxiter`.

Optionally, specify a dictionary of `weights` for each column to
affect the underlying table distance from TableDistances.jl, and
a random number generator `rng` to obtain reproducible results.

## Examples

```julia
KMedoids(3)
KMedoids(4, maxiter=20)
KMedoids(5, weights=Dict(:col1 => 1.0, :col2 => 2.0))
```

## References

* Kaufman, L. & Rousseeuw, P. J. 1990. [Partitioning Around Medoids (Program PAM)]
  (https://onlinelibrary.wiley.com/doi/10.1002/9780470316801.ch2)

* Kaufman, L. & Rousseeuw, P. J. 1991. [Finding Groups in Data: An Introduction to Cluster Analysis]
  (https://www.jstor.org/stable/2532178)
"""
struct KMedoids{W,RNG} <: StatelessFeatureTransform
  k::Int
  tol::Float64
  maxiter::Int
  weights::W
  rng::RNG
end

function KMedoids(k; tol=1e-4, maxiter=10, weights=nothing, rng=Random.default_rng())
  # sanity checks
  _assert(k > 0, "number of clusters must be positive")
  _assert(tol > 0, "tolerance on relative change must be positive")
  _assert(maxiter > 0, "maximum number of iterations must be positive")
  KMedoids(k, tol, maxiter, weights, rng)
end

parameters(transform::KMedoids) = (; k=transform.k)

function applyfeat(transform::KMedoids, feat, prep)
  # retrieve parameters
  k = transform.k
  tol = transform.tol
  maxiter = transform.maxiter
  weights = transform.weights
  rng = transform.rng

  # number of observations
  nobs = _nrows(feat)

  # sanity checks
  k > nobs && throw(ArgumentError("requested number of clusters > number of observations"))

  # normalize variables
  stdfeat = feat |> StdFeats()

  # define table distance
  td = TableDistance(normalize=false, weights=weights)

  # initialize medoids
  medoids = sample(rng, 1:nobs, k, replace=false)

  # retrieve distance type
  s = Tables.subset(stdfeat, 1:1)
  D = eltype(pairwise(td, s))

  # pre-allocate memory for labels and distances
  labels = fill(0, nobs)
  dists = fill(typemax(D), nobs)

  # main loop
  iter = 0
  δcur = mean(dists)
  while iter < maxiter
    # update labels and medoids
    _updatelabels!(td, stdfeat, medoids, labels, dists)
    _updatemedoids!(td, stdfeat, medoids, labels)

    # average distance to medoids
    δnew = mean(dists)

    # break upon convergence
    abs(δnew - δcur) / δcur < tol && break

    # update and continue
    δcur = δnew
    iter += 1
  end

  newfeat = (; cluster=labels) |> Tables.materializer(feat)

  newfeat, nothing
end

function _updatelabels!(td, table, medoids, labels, dists)
  for (k, mₖ) in enumerate(medoids)
    inds = 1:_nrows(table)

    X = Tables.subset(table, inds)
    μ = Tables.subset(table, [mₖ])

    δ = pairwise(td, X, μ)

    @inbounds for i in inds
      if δ[i] < dists[i]
        dists[i] = δ[i]
        labels[i] = k
      end
    end
  end
end

function _updatemedoids!(td, table, medoids, labels)
  for k in eachindex(medoids)
    inds = findall(isequal(k), labels)

    X = Tables.subset(table, inds)

    j = _medoid(td, X)

    @inbounds medoids[k] = inds[j]
  end
end

function _medoid(td, table)
  Δ = pairwise(td, table)
  _, j = findmin(sum, eachcol(Δ))
  j
end

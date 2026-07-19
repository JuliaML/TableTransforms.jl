# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    KMedoids(k; tol=1e-4, maxiter=10, weights=nothing, nmax=2000, rng=Random.default_rng())

Assign labels to rows of table using the `k`-medoids algorithm.

The iterative algorithm is interrupted if the relative change on
the average distance to medoids is smaller than a tolerance `tol`
or if the number of iterations exceeds the maximum number of
iterations `maxiter`.

Optionally, specify a dictionary of `weights` for each column to
affect the underlying table distance from TableDistances.jl, a
maximum number of observations `nmax` to avoid out-of-memory issues,
and a random number generator `rng` to obtain reproducible results.

## Examples

```julia
KMedoids(3)
KMedoids(4, maxiter=20)
KMedoids(5, weights=Dict(:col1 => 1.0, :col2 => 2.0))
```

## References

* Kaufman, L. & Rousseeuw, P. J. 1990. [Partitioning Around Medoids
  (Program PAM)](https://onlinelibrary.wiley.com/doi/10.1002/9780470316801.ch2)

* Kaufman, L. & Rousseeuw, P. J. 1991. [Finding Groups in Data:
  An Introduction to Cluster Analysis](https://www.jstor.org/stable/2532178)
"""
struct KMedoids{W,RNG} <: StatelessFeatureTransform
  k::Int
  tol::Float64
  maxiter::Int
  weights::W
  nmax::Int
  rng::RNG
end

function KMedoids(k; tol=1e-4, maxiter=10, weights=nothing, nmax=2000, rng=Random.default_rng())
  # sanity checks
  _assert(k > 0, "number of clusters must be positive")
  _assert(tol > 0, "tolerance on relative change must be positive")
  _assert(maxiter > 0, "maximum number of iterations must be positive")
  _assert(nmax > 0, "maximum number of observations must be positive")
  KMedoids(k, tol, maxiter, weights, nmax, rng)
end

parameters(transform::KMedoids) = (; k=transform.k)

function applyfeat(transform::KMedoids, feat, prep)
  # retrieve parameters
  k = transform.k
  tol = transform.tol
  maxiter = transform.maxiter
  weights = transform.weights
  nmax = transform.nmax
  rng = transform.rng

  # sanity checks
  k > _nrows(feat) && throw(ArgumentError("requested number of clusters > number of observations"))

  # normalize variables
  stdfeat = feat |> StdFeats()

  # subsample table to avoid out-of-memory issues
  subfeat, inds = _subsample(rng, stdfeat, nmax)

  # number of observations
  nobs = _nrows(subfeat)

  # define table distance
  td = TableDistance(normalize=false, weights=weights)

  # initialize medoids
  medoids = sample(rng, 1:nobs, k, replace=false)

  # retrieve distance type
  s = Tables.subset(subfeat, [1], viewhint=true)
  D = eltype(pairwise(td, s))

  # pre-allocate memory for labels and distances
  labels = fill(0, nobs)
  dists = fill(typemax(D), nobs)

  # main loop
  iter = 0
  δcur = mean(dists)
  while iter < maxiter
    # update labels and medoids
    _updatelabels!(td, subfeat, medoids, labels, dists)
    _updatemedoids!(td, subfeat, medoids, labels)

    # average distance to medoids
    δnew = mean(dists)

    # break upon convergence
    abs(δnew - δcur) / δcur < tol && break

    # update and continue
    δcur = δnew
    iter += 1
  end

  # interpolate in case of subsampling
  ilabels = if nobs < _nrows(feat)
    _interp(labels, inds, stdfeat, td)
  else
    labels
  end

  newfeat = (; label=ilabels) |> Tables.materializer(feat)

  newfeat, nothing
end

function _subsample(rng, table, nmax)
  nobs = _nrows(table)
  inds = nobs > nmax ? sample(rng, 1:nobs, nmax, replace=false) : 1:nobs
  rows = Tables.subset(table, inds, viewhint=true)
  stab = rows |> Tables.materializer(table)
  stab, inds
end

function _updatelabels!(td, table, medoids, labels, dists)
  for (k, mₖ) in enumerate(medoids)
    μ = Tables.subset(table, [mₖ], viewhint=true)
    δ = pairwise(td, table, μ) |> vec
    @inbounds for i in eachindex(δ)
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

    # if cluster is empty, then no medoid to update
    isempty(inds) && continue

    # compute new medoid for cluster k
    clust = Tables.subset(table, inds, viewhint=true)
    _, j = findmin(sum, eachcol(pairwise(td, clust)))

    @inbounds medoids[k] = inds[j]
  end
end

function _interp(labels, inds, table, td)
  nobs = _nrows(table)

  ilabels = fill(0, nobs)
  ilabels[inds] .= labels

  X = Tables.subset(table, inds, viewhint=true)
  s = _searcher(X, td)

  for i in setdiff(1:nobs, inds)
    x = Tables.subset(table, [i], viewhint=true)
    j = _search(s, x)
    ilabels[i] = labels[j]
  end

  ilabels
end

function _searcher(X, td)
  # check if all variables are continuous
  cols = Tables.columns(X)
  vars = Tables.columnnames(cols)
  allcont = all(vars) do var
    x = Tables.getcolumn(cols, var)
    elscitype(x) <: Continuous
  end

  # use KDTree if all variables are continuous
  if allcont
    data = Tables.matrix(X)
    KDTree(transpose(data))
  else
    X, td
  end
end

_search(s::KDTree, x) = nn(s, Tables.matrix(x) |> vec) |> first

_search((X, td), x) = pairwise(td, X, x) |> vec |> argmin

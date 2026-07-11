# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    ProjectionPursuit(; tol=1e-6, maxiter=100, deg=5, perc=0.9, n=100, rng=Random.default_rng())

The projection pursuit multivariate transform converts any multivariate distribution into
the standard multivariate Gaussian distribution.

This iterative algorithm repeatedly finds a direction of projection `α` that maximizes a score of
non-Gaussianity known as the projection index `I(α)`. The samples projected along `α` are then
transformed with the [`Quantile`](@ref) transform to remove the non-Gaussian structure. The
other coordinates in the rotated orthonormal basis `Q = [α ...]` are left untouched.

The non-singularity of `Q` is controlled by assuring that `norm(det(Q)) ≥ tol`. The iterative 
process terminates whenever the transformed samples are "more Gaussian" than `perc`% of `n`
randomly generated samples from the standard multivariate Gaussian distribution, or when the 
number of iterations reaches a maximum `maxiter`.

The degree of the Legendre polynomial used to approximate the projection index is controlled
by `deg`. The random number generator `rng` is used to generate the random samples from the
standard multivariate Gaussian distribution.

## Examples

```julia
ProjectionPursuit()
ProjectionPursuit(deg=10)
ProjectionPursuit(perc=0.85, n=50)
ProjectionPursuit(tol=1e-4, maxiter=250, deg=5, perc=0.95, n=100)

# with rng
using Random
rng = Xoshiro(123)
ProjectionPursuit(perc=0.85, n=50, rng=rng)
```

See [https://doi.org/10.2307/2289161](https://doi.org/10.2307/2289161) for 
further details.
"""
struct ProjectionPursuit{T,RNG} <: StatelessFeatureTransform
  tol::T
  maxiter::Int
  deg::Int
  perc::T
  n::Int
  rng::RNG
end

ProjectionPursuit(; tol=1e-6, maxiter=100, deg=5, perc=0.9, n=100, rng=Random.default_rng()) =
  ProjectionPursuit{typeof(tol),typeof(rng)}(tol, maxiter, deg, perc, n, rng)

assertions(::ProjectionPursuit) = [scitypeassert(Continuous)]

parameters(transform::ProjectionPursuit) = (tol=transform.tol, deg=transform.deg, perc=transform.perc, n=transform.n)

isrevertible(::Type{<:ProjectionPursuit}) = true

# transforms a row of random variables into a convex combination 
# of random variables with values in [-1,1] and standard normal distribution
rscore(Z, α) = 2 .* cdf.(Normal(), Z * α) .- 1

# projection index of sample along a given direction
function pindex(transform, Z, α)
  d = transform.deg
  r = rscore(Z, α)
  I = (3 / 2) * mean(r)^2
  if d > 1
    Pⱼ₋₂, Pⱼ₋₁ = ones(length(r)), r
    for j in 2:d
      Pⱼ₋₂, Pⱼ₋₁ = Pⱼ₋₁, (1 / j) * ((2j - 1) * r .* Pⱼ₋₁ - (j - 1) * Pⱼ₋₂)
      I += ((2j + 1) / 2) * (mean(Pⱼ₋₁))^2
    end
  end
  I
end

# j-th element of the canonical basis in ℝᵈ
basis(d, j) = float(1:d .== j)

# index for all vectors in the canonical basis
function pbasis(transform, Z)
  q = size(Z, 2)
  [pindex(transform, Z, basis(q, j)) for j in 1:q]
end

# projection index of the standard multivariate Gaussian
function gaussquantiles(transform, N, q)
  n = transform.n
  p = 1.0 - transform.perc
  rng = transform.rng
  Is = [pbasis(transform, randn(rng, N, q)) for i in 1:n]
  I = reduce(hcat, Is)
  quantile.(eachrow(I), p)
end

function alphaguess(transform, Z)
  q = size(Z, 2)

  # objective function
  func(α) = pindex(transform, Z, α)

  # evaluate objective along axes
  j = argmax(j -> func(basis(q, j)), 1:q)
  α = basis(q, j)
  I = func(α)

  # evaluate objective along diagonals
  diag(α, s, e) = (1 / √(2 + 2s * α ⋅ e)) * (α + s * e)
  for eᵢ in basis.(q, 1:q)
    d₊ = diag(α, +1, eᵢ)
    d₋ = diag(α, -1, eᵢ)
    f₊ = func(d₊)
    f₋ = α ⋅ eᵢ != 1.0 ? func(d₋) : 0.0
    f, d = f₊ > f₋ ? (f₊, d₊) : (f₋, d₋)
    if f > I
      α = d
      I = f
    end
  end

  α
end

function neldermead(transform, Z, α₀)
  f(α) = -pindex(transform, Z, α ./ norm(α))
  optimise(f, α₀, 1 / 2, xtol_rel=10eps()) |> first
end

function alphamax(transform, Z)
  α = alphaguess(transform, Z)
  neldermead(transform, Z, α)
end

function orthobasis(transform, α)
  tol = transform.tol
  rng = transform.rng
  q = length(α)
  Q, R = qr([α rand(rng, q, q - 1)])
  while norm(diag(R)) < tol
    Q, R = qr([α rand(rng, q, q - 1)])
  end
  Q
end

function rmstructure(transform, Z, α)
  # find orthonormal basis for rotation
  Q = orthobasis(transform, α)

  # remove structure of first rotated axis
  newtable, qcache = apply(Quantile(1), Tables.table(Z * Q))

  # undo rotation, i.e recover original axis-aligned features
  Z₊ = Tables.matrix(newtable) * Q'

  Z₊, (Q, qcache)
end

sphering() = Quantile() → EigenAnalysis(:VDV)

function applyfeat(transform::ProjectionPursuit, feat, prep)
  # original columns names
  cols = Tables.columns(feat)
  onames = Tables.columnnames(cols)

  # preprocess the data to approximately spherical shape
  ptable, pcache = apply(sphering(), feat)

  # initialize scores and Gaussian quantiles
  Z = Tables.matrix(ptable)
  I = pbasis(transform, Z)
  g = gaussquantiles(transform, size(Z)...)

  iter = 0
  caches = []
  while any(I .> g) && iter ≤ transform.maxiter
    # choose direction with maximum projection index
    α = alphamax(transform, Z)

    # remove non-Gaussian structure
    Z, cache = rmstructure(transform, Z, α)

    # update the scores along original axes
    I = pbasis(transform, Z)

    # store cache and continue
    push!(caches, cache)
    iter += 1
  end

  # new column names
  names = Symbol.(:PP, 1:size(Z, 2))

  𝒯 = (; zip(names, eachcol(Z))...)
  newtable = 𝒯 |> Tables.materializer(feat)
  newtable, (pcache, caches, onames)
end

function revertfeat(::ProjectionPursuit, newfeat, fcache)
  # caches to retrieve transform steps
  pcache, caches, onames = fcache

  Z = Tables.matrix(newfeat)
  for (Q, qcache) in reverse(caches)
    table = revert(Quantile(1), Tables.table(Z * Q), qcache)
    Z = Tables.matrix(table) * Q'
  end

  table = revert(sphering(), Tables.table(Z), pcache)
  Z = Tables.matrix(table)

  𝒯 = (; zip(onames, eachcol(Z))...)
  𝒯 |> Tables.materializer(newfeat)
end

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    ProjectionPursuit(;tol=1e-6, maxiter=100, deg=5, perc=.9, n=100)

The projection pursuit multivariate transform converts any multivariate distribution into
the standard multivariate Gaussian distribution.

This iterative algorithm repeatedly finds a direction of projection `α` that maximizes a score of
non-Gaussianity known as the projection index `I(α)`. The samples projected along `α` are then
transformed with the [`Quantile`](@ref) transform to remove the non-Gaussian structure. The
other coordinates in the rotated orthonormal basis `Q = [α ...]` are left untouched.

The non-singularity of Q is controlled by assuring that norm(det(Q)) ≥ `tol`. The iterative 
process terminates whenever the transformed samples are "more Gaussian" than `perc`% of `n`
randomly generated samples from the standard multivariate Gaussian distribution, or when the 
number of iterations reaches a maximum `maxiter`.

# Examples

```julia
ProjectionPursuit()
ProjectionPursuit(deg=10)
ProjectionPursuit(perc=.85, n=50)
ProjectionPursuit(tol=1e-4, maxiter=250, deg=5, perc=.95, n=100)
```

See [https://doi.org/10.2307/2289161](https://doi.org/10.2307/2289161) for 
further details.
"""

struct ProjectionPursuit{T} <: StatelessFeatureTransform
  tol::T
  maxiter::Int
  deg::Int
  perc::T
  n::Int
end

ProjectionPursuit(;tol=1e-6, maxiter=100, deg=5, perc=.95, n=100) =
  ProjectionPursuit{typeof(tol)}(tol, maxiter, deg, perc, n)

isrevertible(::Type{<:ProjectionPursuit}) = true

# transforms a row of random variables into a convex combination 
# of random variables with values in [-1,1] and standard normal distribution
function rscore(Z, α)
  ᾱ = (1/norm(α)) .* α
  X = Z * ᾱ
  2 .* cdf.(Normal(), X) .- 1
end

# projection index of sample along a given direction
function pindex(transform, Z, α)
  d = transform.deg
  r = rscore(Z, α)
  I = (3/2) * mean(r)^2
  if d > 1
    Pⱼ₋₂, Pⱼ₋₁ = ones(length(r)), r
    for j = 2:d
      Pⱼ₋₂, Pⱼ₋₁ = 
        Pⱼ₋₁, (1/j) * ((2j-1) * r .* Pⱼ₋₁ - (j-1) * Pⱼ₋₂)
      I += ((2j+1)/2) * (mean(Pⱼ₋₁))^2
    end
  end
  I
end

# j-th element of the canonical basis in ℝᵈ
basis(d, j) = 1:d .== j

# index for all vectors in the canonical basis
function pbasis(transform, Z)
  q = size(Z, 2)
  [pindex(transform, Z, basis(q, j)) for j in 1:q]
end

# projection index of the standard multivariate Gaussian
function gaussquantiles(transform, N, q)
  n = transform.n
  p = transform.perc
  Is = [pbasis(transform, randn(N, q)) for i in 1:n]
  I  = reduce(hcat, Is)
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
  diag(α, s, e) = (1/√(2+2s*α'*e)) * (α + s*e)
  for eᵢ in eachcol(E)
    d₊ = diag(α, +1, eᵢ)
    d₋ = diag(α, -1, eᵢ)
    f₊ = func(d₊)
    f₋ = α'*eᵢ != 1.0 ? func(d₋) : 0.0
    f, d = f₊ > f₋ ? (f₊, d₊) : (f₋, d₋)
    if f > Iₐ
      α = d
      I = f
    end
  end
  
  α
end

function neldermead(transform, Z, α₀)
  f(α) = -pindex(transform, Z, α)
  op = optimize(f, α₀)
  minimizer(op)
end

function alphamax(transform, Z)
  α = alphaguess(transform, Z)
  neldermead(transform, Z, α)  
end

function rmstructure(transform, Z, α)
  q = length(α)
  
  # find orthonormal basis for rotation
  Q, R = qr([α rand(q,q-1)])
  while norm(diag(R)) < transform.tol
    Q, R = qr([α rand(q,q-1)])
  end

  # rotate features with orthonormal basis
  table = Tables.table(Z * Q)
  
  # remove structure of first rotated axis
  newtable, cache = apply(Quantile(1), table)
  
  # undo rotation, i.e recover original axis-aligned features
  Z₊ = Tables.matrix(newtable) * Q'
  
  Z₊, Q, cache
end

function applyfeat(transform::ProjectionPursuit, table, prep) 
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)

  trans = Quantile() → EigenAnalysis(:VDV)
  ttable, tcache = apply(trans, table)

  Z = Tables.matrix(ttable)
  N, q = size(Z)
  
  # initialize scores along original axis-aligned features
  I = pbasis(transform, Z)

  # standard Gaussian quantiles
  g = gaussquantiles(transform, N, q) 

  iter = 0
  caches = []
  while any(g .< I) && iter ≤ transform.maxiter
    α = alphamax(transform, Z)
    Z, Q, cache = rmstructure(transform, Z, α)
    I = pbasis(transform, Z)
    push!(caches, (Q, cache))
    iter += 1
  end

  𝒯 = (; zip(names, eachcol(Z))...)
  newtable = 𝒯 |> Tables.materializer(table)
  newtable, (caches, tcache)
end

function revertfeat(::ProjectionPursuit, newtable, fcache)
  cols = Tables.columns(newtable)
  names = Tables.columnnames(cols)
  caches, tcache = fcache

  t = newtable
  for (Q, cache) in reverse(caches)
    # rotate the data 
    Z = Tables.matrix(t) * Q

    # revert the transform
    table  = revert(Quantile(1), Tables.table(Z), cache)
    t = Tables.matrix(table) * Q'
  end
  
  trans = Quantile() → EigenAnalysis(:VDV)
  tablerev = revert(trans, t, tcache)

  Z = Tables.matrix(tablerev)
  𝒯 = (; zip(names, eachcol(Z))...)
  newtable = 𝒯 |> Tables.materializer(newtable)
end
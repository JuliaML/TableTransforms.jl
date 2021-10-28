# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    EigenAnalysis(proj)

The eigenanalysis of the covariance with a given projection `proj`.

## Projections

* `:V` - Uncorrelated variables (PCA transform)
* `:VD` - Uncorrelated variables and variance one (DRS transform)
* `:VDV` - Uncorrelated variables and variance one (SDS transformation)

The `:V` projection, also called PCA transform, rotates the multivariate data
so that the resultant principal components in the data matrix are uncorrelated,
where off-diagonal entries of its correlation matrix Σ are zero.

The `:VD` projection, also known as DRS transform, is a technique that belongs to
a class of rotations that are close extensions of PCA, yielding variables that
in addition to being uncorrelated, also have a variance of one. The combination
of these properties yields an identity covariance matrix.

The `:VDV` projection, or SDS transform, is also a technique that that rotates the data.
The difference between the two sphereing methods, SDS and DRS, is the additional
multiplication by Vᵀ, which projects the orthogonal variables back onto the basis of the
original variables. As in DRS, the D is the inverse of the squared root of eigenvalues matrix.
"""
struct EigenAnalysis <: Transform
  proj::Symbol
end

isrevertible(::Type{EigenAnalysis}) = true

function pcamatrices(X)
  Σ = cov(X)
  λ, V = eigen(Σ)
  V, transpose(V)
end

function drsmatrices(X)
  Σ = cov(X)
  λ, V = eigen(Σ)
  Λ = Diagonal(sqrt.(λ))
  S = V * inv(Λ)
  S, inv(S)
end

function sdsmatrices(X)
  Σ = cov(X)
  λ, V = eigen(Σ)
  Λ = Diagonal(sqrt.(λ))
  S = V * inv(Λ) * transpose(V)
  S, inv(S)
end

function perform(transform::EigenAnalysis, X)
  transform.proj == :V && return pcamatrices(X)
  transform.proj == :VD && return drsmatrices(X)
  transform.proj == :VDV && return sdsmatrices(X)
end

function apply(transform::EigenAnalysis, table)
  @assert transform.proj ∈ [:V, :VD, :VDV] "eigen analysis not suported"

  # sanity checks
  sch = schema(table)
  names = sch.names
  types = sch.scitypes
  @assert all(T <: Continuous for T in types) "columns must hold continuous variables"

  X = Tables.matrix(table)
  μ = mean(X, dims=1)
  X = X .- μ
  Γ, Γ⁻¹ = perform(transform, X)
  Y = X * Γ

  # table with transformed columns
  𝒯 = (; zip(names, eachcol(Y))...)
  newtable = 𝒯 |> Tables.materializer(table)

  newtable, (Γ⁻¹, μ)
end

function revert(::EigenAnalysis, newtable, cache)
  # sanity checks
  sch = schema(newtable)
  names = sch.names
  types = sch.scitypes
  @assert all(T <: Continuous for T in types) "columns must hold continuous variables"

  Γ⁻¹, μ = first(cache), last(cache)

  Y = Tables.matrix(newtable)
  X = Y * Γ⁻¹
  X = X .+ μ

  # table with original columns
  𝒯 = (; zip(names, eachcol(X))...)
  𝒯 |> Tables.materializer(newtable)
end
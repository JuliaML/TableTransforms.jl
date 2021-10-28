# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    EigenAnalysis(proj)

The EigenAnalysis(proj) transform returns:
* proj = :V: A table with uncorrelated variables (PCA transformation).
* proj = :VD: A table with uncorrelated variables and variance 1, where D is the inverse of squared root eigenvalues matrix and V is the eigenvectors matrix (DRS transformation).
* proj = :VDV: A table with uncorrelated variables and variance 1, where D is the inverse of squared root eigenvalues matrix and V is the eigenvectors matrix (SDS transformation, which projects the orthogonal variables back onto the basis of the original variables).
"""
struct EigenAnalysis <: Transform
  proj::Symbol
end

isrevertible(::Type{EigenAnalysis}) = true

function pcamatrices(X)
  Σ = cov(X)
  V = eigvecs(Σ)
  V, transpose(V)
end

function drsmatrices(X)
  Σ = cov(X)
  λ,  V = eigen(Σ)
  Λ = Diagonal(sqrt.(λ))
  S = V * inv(Λ)
  S, inv(S)
end

function sdsmatrices(X)
  Σ = cov(X)
  λ,  V = eigen(Σ)
  Λ = Diagonal(sqrt.(λ))
  S = V * inv(Λ) * transpose(V)
  S, inv(S)
end

function compute(E::EigenAnalysis, X)
  E.proj == :V && return pcamatrices(X)
  E.proj == :VD && return drsmatrices(X)
  E.proj == :VDV && return sdsmatrices(X)
end

function apply(E::EigenAnalysis, table)
  @assert E.proj ∈ [:V, :VD, :VDV] "eigen analysis not suported"

  # sanity checks
  sch = schema(table)
  names = sch.names
  types = sch.scitypes
  @assert all(T <: Continuous for T in types) "columns must hold continuous variables"

  X = Tables.matrix(table)
  means = mean(X, dims=1)
  X = X .- means
  Γ, Γ⁻¹ = compute(E, X)
  Y = X * Γ

  # table with transformed columns
  𝒯 = (; zip(names, eachcol(Y))...)
  newtable = 𝒯 |> Tables.materializer(table)

  newtable, (Γ⁻¹, means)
end

function revert(::EigenAnalysis, newtable, cache)
  # sanity checks
  sch = schema(newtable)
  names = sch.names
  types = sch.scitypes
  @assert all(T <: Continuous for T in types) "columns must hold continuous variables"

  Γ⁻¹, means = first(cache), last(cache)

  Y = Tables.matrix(newtable)
  X = Y * Γ⁻¹
  X = X .+ means

  # table with original columns
  𝒯 = (; zip(names, eachcol(X))...)
  𝒯 |> Tables.materializer(newtable)
end
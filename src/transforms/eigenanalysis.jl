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

function perform(E::EigenAnalysis, X)
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
  μ = mean(X, dims=1)
  X = X .- μ
  Γ, Γ⁻¹ = perform(E, X)
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
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

The `:V` projection used in the PCA transform projects the data on the eigenvectors
V of the covariance matrix.

The `:VD` projection used in the DRS transform. Similar to the `:V` projection,
but the eigenvectors are multiplied by the squared inverse of the eigenvalues D.

The `:VDV` projection used in the SDS transform. Similar to the `:VD` transform,
but the data is projected back to the basis of the original variables using the Vᵀ matrix.

See [https://geostatisticslessons.com/lessons/sphereingmaf](https://geostatisticslessons.com/lessons/sphereingmaf)
for more details about these three variants of eigenanalysis.
"""
struct EigenAnalysis <: Transform
  proj::Symbol
end

isrevertible(::Type{EigenAnalysis}) = true

function pcaproj(λ, V)
  V, transpose(V)
end

function drsproj(λ, V)
  λₛ = sqrt.(λ)
  Λᵢ = Diagonal(1 ./ λₛ)
  Λₛ = Diagonal(λₛ)
  S = V * Λᵢ
  Sᵢ = Λₛ * transpose(V)
  S, Sᵢ
end

function sdsproj(λ, V)
  λₛ = sqrt.(λ)
  Λᵢ = Diagonal(1 ./ λₛ)
  Λₛ = Diagonal(λₛ)
  S = V * Λᵢ * transpose(V)
  Sᵢ = V * Λₛ * transpose(V)
  S, Sᵢ
end

function matrices(transform::EigenAnalysis, λ, V)
  transform.proj == :V && return pcaproj(λ, V)
  transform.proj == :VD && return drsproj(λ, V)
  transform.proj == :VDV && return sdsproj(λ, V)
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
  Σ = cov(X)
  λ, V = eigen(Σ)
  Γ, Γ⁻¹ = matrices(transform, λ, V)
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

"""
    PCA()

The PCA transform is a shortcut for
`ZScore() → EigenAnalysis(:V)`.
"""
PCA() = ZScore() → EigenAnalysis(:V)

"""
    DRS()

The DRS transform is a shortcut for
`ZScore() → EigenAnalysis(:VD)`.
"""
DRS() = ZScore() → EigenAnalysis(:VD)

"""
    SDS()

The SDS transform is a shortcut for
`ZScore() → EigenAnalysis(:VDV)`.
"""
SDS() = ZScore() → EigenAnalysis(:VDV)
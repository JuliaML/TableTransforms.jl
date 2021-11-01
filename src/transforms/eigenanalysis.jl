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

  function EigenAnalysis(proj)
    @assert proj ∈ (:V, :VD, :VDV) "invalid projection"
    new(proj)
  end
end

assertions(::Type{EigenAnalysis}) = [assert_continuous]

isrevertible(::Type{EigenAnalysis}) = true

function pcaproj(λ, V)
  V, transpose(V)
end

function drsproj(λ, V)
  Λ = Diagonal(sqrt.(λ))
  S = V * inv(Λ)
  S⁻¹ = Λ * transpose(V)
  S, S⁻¹
end

function sdsproj(λ, V)
  Λ = Diagonal(sqrt.(λ))
  S = V * inv(Λ) * transpose(V)
  S⁻¹ = V * Λ * transpose(V)
  S, S⁻¹
end

function matrices(transform::EigenAnalysis, λ, V)
  transform.proj == :V && return pcaproj(λ, V)
  transform.proj == :VD && return drsproj(λ, V)
  transform.proj == :VDV && return sdsproj(λ, V)
end

function apply(transform::EigenAnalysis, table)
  # basic checks
  for assertion in assertions(transform)
    assertion(table)
  end

  # original columns names
  names = Tables.columnnames(table)

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
  # transformed column names
  names = Tables.columnnames(newtable)

  Y = Tables.matrix(newtable)
  Γ⁻¹, μ = cache
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
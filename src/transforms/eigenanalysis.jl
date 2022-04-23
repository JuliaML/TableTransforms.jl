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

# Examples

```julia
EigenAnalysis(:V)
EigenAnalysis(:VD)
EigenAnalysis(:VDV)
```
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

function apply(transform::EigenAnalysis, table)
  # basic checks
  for assertion in assertions(transform)
    assertion(table)
  end

  # original columns names
  names = Tables.columnnames(table)

  # table as matrix
  X = Tables.matrix(table)

  # center the data
  μ = mean(X, dims=1)
  Y = X .- μ

  # eigenanalysis of covariance
  S, S⁻¹ = eigenmatrices(transform, Y)

  # project the data
  Z = Y * S

  # table with transformed columns
  𝒯 = (; zip(names, eachcol(Z))...)
  newtable = 𝒯 |> Tables.materializer(table)

  newtable, (μ, S, S⁻¹)
end

function revert(::EigenAnalysis, newtable, cache)
  # transformed column names
  names = Tables.columnnames(newtable)

  # table as matrix
  Z = Tables.matrix(newtable)

  # retrieve cache
  μ, S, S⁻¹ = cache

  # undo projection
  Y = Z * S⁻¹

  # undo centering
  X = Y .+ μ

  # table with original columns
  𝒯 = (; zip(names, eachcol(X))...)
  𝒯 |> Tables.materializer(newtable)
end

function reapply(transform::EigenAnalysis, table, cache)
  # basic checks
  for assertion in assertions(transform)
    assertion(table)
  end

  # original columns names
  names = Tables.columnnames(table)

  # table as matrix
  X = Tables.matrix(table)

  # retrieve cache
  μ, S, S⁻¹ = cache

  # center the data
  Y = X .- μ

  # project the data
  Z = Y * S

  # table with transformed columns
  𝒯 = (; zip(names, eachcol(Z))...)
  𝒯 |> Tables.materializer(table)
end

function eigenmatrices(transform, Y)
  proj = transform.proj

  Σ = cov(Y)
  λ, V = eigen(Σ)

  if proj == :V
    S   = V
    S⁻¹ = transpose(V)
  elseif proj == :VD
    Λ   = Diagonal(sqrt.(λ))
    S   = V * inv(Λ)
    S⁻¹ = Λ * transpose(V)
  elseif proj == :VDV
    Λ   = Diagonal(sqrt.(λ))
    S   = V * inv(Λ) * transpose(V)
    S⁻¹ = V * Λ * transpose(V)
  end

  S, S⁻¹
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
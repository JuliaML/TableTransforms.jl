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
struct EigenAnalysis{T<:Union{Int,Colon}} <: Transform
  proj::Symbol
  ndim::T

  function EigenAnalysis(proj, ndim=:)
    @assert proj ∈ (:V, :VD, :VDV) "invalid projection"
    new(proj, ndim)
  end
end

assertions(::Type{EigenAnalysis}) = [assert_continuous]

isrevertible(::Type{EigenAnalysis}) = true

_ndim(ndim, X) = ndim
_ndim(ndim::Colon, X) = size(X, 2)

function apply(transform::EigenAnalysis, table)
  # basic checks
  for assertion in assertions(transform)
    assertion(table)
  end

  # output dim
  ndim = _ndim(transform.ndim, X)

  # table as matrix
  X = Tables.matrix(table)

  # eigenanalysis of covariance
  S, S⁻¹ = eigenmatrices(transform, Y)

  # project the data
  Y = X * S

  # discarted and selected coluns
  D = Y[:, ndim+1:end]
  Y = Y[:, 1:ndim]

  # column names
  names = [Symbol(:pc, d) for d in 1:ndim]

  # table with transformed columns
  𝒯 = (; zip(names, eachcol(Y))...)
  newtable = 𝒯 |> Tables.materializer(table)

  newtable, (D, S, S⁻¹)
end

function revert(::EigenAnalysis, newtable, cache)
  # transformed column names
  cols = Tables.columns(newtable)
  names = Tables.columnnames(cols)

  # table as matrix
  Y = Tables.matrix(newtable)

  # retrieve cache
  D, S, S⁻¹ = cache

  # undo projection
  X = hcat(Y, D) * S⁻¹

  # table with original columns
  𝒯 = (; zip(names, eachcol(X))...)
  𝒯 |> Tables.materializer(newtable)
end

function reapply(transform::EigenAnalysis, table, cache)
  # basic checks
  for assertion in assertions(transform)
    assertion(table)
  end

  # output dim
  ndim = _ndim(transform.ndim, X)

  # table as matrix
  X = Tables.matrix(table)

  # retrieve cache
  D, S, S⁻¹ = cache

  # project the data
  Y = X * S

  # selected coluns
  Y = Y[:, 1:ndim]

  # column names
  names = [Symbol(:pc, d) for d in 1:ndim]

  # table with transformed columns
  𝒯 = (; zip(names, eachcol(Y))...)
  𝒯 |> Tables.materializer(table)
end

function eigenmatrices(transform, Y)
  proj = transform.proj

  Σ = cov(Y)
  F = eigen(Σ)
  λ = F.values[end:-1:1]
  V = F.vectors[:, end:-1:1]

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

See also: [`ZScore`](@ref), [`EigenAnalysis`](@ref).
"""
PCA() = ZScore() → EigenAnalysis(:V)

"""
    DRS()

The DRS transform is a shortcut for
`ZScore() → EigenAnalysis(:VD)`.

See also: [`ZScore`](@ref), [`EigenAnalysis`](@ref).
"""
DRS() = ZScore() → EigenAnalysis(:VD)

"""
    SDS()

The SDS transform is a shortcut for
`ZScore() → EigenAnalysis(:VDV)`.

See also: [`ZScore`](@ref), [`EigenAnalysis`](@ref).
"""
SDS() = ZScore() → EigenAnalysis(:VDV)

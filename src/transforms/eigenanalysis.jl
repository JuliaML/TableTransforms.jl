# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    EigenAnalysis(proj; [maxdim], [pratio])

The eigenanalysis of the covariance with a given projection `proj`.
Optionally specify the maximum number of dimensions in the output
`maxdim` and the percentage of variance to retain `pratio`.

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
EigenAnalysis(:V, maxdim=3)
EigenAnalysis(:VD, pratio=0.99)
EigenAnalysis(:VDV, maxdim=3, pratio=0.99)
```
"""
struct EigenAnalysis <: FeatureTransform
  proj::Symbol
  maxdim::Union{Int,Nothing}
  pratio::Float64

  function EigenAnalysis(proj, maxdim, pratio)
    _assert(proj ∈ (:V, :VD, :VDV), "invalid projection")
    _assert(0 ≤ pratio ≤ 1, "invalid pratio")
    new(proj, maxdim, pratio)
  end
end

EigenAnalysis(proj; maxdim=nothing, pratio=1.0) = EigenAnalysis(proj, maxdim, pratio)

assertions(::EigenAnalysis) = [scitypeassert(Continuous)]

isrevertible(::Type{EigenAnalysis}) = true

function applyfeat(transform::EigenAnalysis, feat, prep)
  # original columns names
  cols = Tables.columns(feat)
  onames = Tables.columnnames(cols)

  # table as matrix
  X = Tables.matrix(feat)

  # center the data
  μ = mean(X, dims=1)
  Y = X .- μ

  # eigenanalysis of covariance
  S, S⁻¹ = eigenmatrices(transform, Y)

  # project the data
  Z = Y * S

  # column names
  names = Symbol.(:PC, 1:size(Z, 2))

  # table with transformed columns
  𝒯 = (; zip(names, eachcol(Z))...)
  newfeat = 𝒯 |> Tables.materializer(feat)

  newfeat, (μ, S, S⁻¹, onames)
end

function revertfeat(::EigenAnalysis, newfeat, fcache)
  # table as matrix
  Z = Tables.matrix(newfeat)

  # retrieve cache
  μ, S, S⁻¹, onames = fcache

  # undo projection
  Y = Z * S⁻¹

  # undo centering
  X = Y .+ μ

  # table with original columns
  𝒯 = (; zip(onames, eachcol(X))...)
  𝒯 |> Tables.materializer(newfeat)
end

function reapplyfeat(transform::EigenAnalysis, feat, fcache)
  # table as matrix
  X = Tables.matrix(feat)

  # retrieve cache
  μ, S, S⁻¹, onames = fcache

  # center the data
  Y = X .- μ

  # project the data
  Z = Y * S

  # column names
  names = Symbol.(:PC, 1:size(Z, 2))

  # table with transformed columns
  𝒯 = (; zip(names, eachcol(Z))...)
  𝒯 |> Tables.materializer(feat)
end

_maxdim(maxdim::Int, Y) = maxdim
_maxdim(::Nothing, Y) = size(Y, 2)

function outdim(transform, Y, λ)
  pratio = transform.pratio
  csums = cumsum(λ)
  ratios = csums ./ last(csums)
  mdim = _maxdim(transform.maxdim, Y)
  pdim = findfirst(≥(pratio), ratios)
  min(mdim, pdim)
end

function eigenmatrices(transform, Y)
  proj = transform.proj

  Σ = cov(Y)
  λ, V = eigen(Σ, sortby=λ -> -real(λ))

  if proj == :V
    S = V
    S⁻¹ = transpose(V)
  elseif proj == :VD
    Λ = Diagonal(sqrt.(λ))
    S = V * inv(Λ)
    S⁻¹ = Λ * transpose(V)
  elseif proj == :VDV
    Λ = Diagonal(sqrt.(λ))
    S = V * inv(Λ) * transpose(V)
    S⁻¹ = V * Λ * transpose(V)
  end

  d = outdim(transform, Y, λ)

  S[:, 1:d], S⁻¹[1:d, :]
end

"""
    PCA([options])

Principal component analysis.

See [`EigenAnalysis`](@ref) for detailed
description of the available options.

# Examples

```julia
PCA(maxdim=2)
PCA(pratio=0.86)
PCA(maxdim=2, pratio=0.86)
```

## Notes

* `PCA()` is shortcut for `ZScore() → EigenAnalysis(:V)`.
"""
PCA(; maxdim=nothing, pratio=1.0) = ZScore() → EigenAnalysis(:V, maxdim, pratio)

"""
    DRS([options])

Dimension reduction sphering.

See [`EigenAnalysis`](@ref) for detailed
description of the available options.

# Examples

```julia
DRS(maxdim=3)
DRS(pratio=0.87)
DRS(maxdim=3, pratio=0.87)
```

## Notes

* `DRS()` is shortcut for `ZScore() → EigenAnalysis(:VD)`.
"""
DRS(; maxdim=nothing, pratio=1.0) = ZScore() → EigenAnalysis(:VD, maxdim, pratio)

"""
    SDS([options])

Standardized data sphering.

See [`EigenAnalysis`](@ref) for detailed
description of the available options.

# Examples

```julia
SDS()
SDS(maxdim=4)
SDS(pratio=0.88)
SDS(maxdim=4, pratio=0.88)
```

## Notes

* `SDS()` is shortcut for `ZScore() → EigenAnalysis(:VDV)`.
"""
SDS(; maxdim=nothing, pratio=1.0) = ZScore() → EigenAnalysis(:VDV, maxdim, pratio)

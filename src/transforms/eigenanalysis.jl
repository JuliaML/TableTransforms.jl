# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    EigenAnalysis(proj; maxdim=nothing, pratio=0.99)

The eigenanalysis of the covariance with a given projection `proj`.
`maxdim` keyword argument defines the maximum number of dimensions of the output.
`pratio` is the percentage ratio of the variances that will be preserved.

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
EigenAnalysis(:VD, pratio=0.89)
EigenAnalysis(:VDV, maxdim=3, pratio=0.89)
```
"""
struct EigenAnalysis <: Transform
  proj::Symbol
  maxdim::Union{Int,Nothing}
  pratio::Float64

  function EigenAnalysis(proj, maxdim, pratio)
    @assert proj ∈ (:V, :VD, :VDV) "Invalid projection."
    @assert 0 ≤ pratio ≤ 1 "Invalid pratio."
    new(proj, maxdim, pratio)
  end
end

EigenAnalysis(proj; maxdim=nothing, pratio=0.99) = 
  EigenAnalysis(proj, maxdim, pratio)

assertions(::Type{EigenAnalysis}) = [assert_continuous]

isrevertible(::Type{EigenAnalysis}) = true

function apply(transform::EigenAnalysis, table)
  # basic checks
  for assertion in assertions(transform)
    assertion(table)
  end

  # original columns names
  cols = Tables.columns(table)
  onames = Tables.columnnames(cols)

  # table as matrix
  X = Tables.matrix(table)

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
  newtable = 𝒯 |> Tables.materializer(table)

  newtable, (μ, S, S⁻¹, onames)
end

function revert(::EigenAnalysis, newtable, cache)
  # table as matrix
  Z = Tables.matrix(newtable)

  # retrieve cache
  μ, S, S⁻¹, onames = cache

  # undo projection
  Y = Z * S⁻¹

  # undo centering
  X = Y .+ μ

  # table with original columns
  𝒯 = (; zip(onames, eachcol(X))...)
  𝒯 |> Tables.materializer(newtable)
end

function reapply(transform::EigenAnalysis, table, cache)
  # basic checks
  for assertion in assertions(transform)
    assertion(table)
  end

  # table as matrix
  X = Tables.matrix(table)

  # retrieve cache
  μ, S, S⁻¹, onames = cache

  # center the data
  Y = X .- μ

  # project the data
  Z = Y * S

  # column names
  names = Symbol.(:PC, 1:size(Z, 2))

  # table with transformed columns
  𝒯 = (; zip(names, eachcol(Z))...)
  𝒯 |> Tables.materializer(table)
end

_maxdim(maxdim::Int, Y) = maxdim
_maxdim(::Nothing, Y) = size(Y, 2)

function outdim(transform, Y, λ)
  pratio = transform.pratio
  csums  = cumsum(λ) 
  ratios = csums ./ last(csums)
  mdim   = _maxdim(transform.maxdim, Y)
  pdim   = findfirst(≥(pratio), ratios)
  min(mdim, pdim)
end

function eigenmatrices(transform, Y)
  proj = transform.proj

  Σ = cov(Y)
  λ, V = eigen(Σ, sortby=λ -> -real(λ))

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

  d = outdim(transform, Y, λ)

  S[:, 1:d], S⁻¹[1:d, :]
end

"""
    PCA(; maxdim=nothing, pratio=0.99)

The PCA transform is a shortcut for
`ZScore() → EigenAnalysis(:V; maxdim, pratio)`.

See also: [`ZScore`](@ref), [`EigenAnalysis`](@ref).

# Examples

```julia
PCA(maxdim=2)
PCA(pratio=0.86)
PCA(maxdim=2, pratio=0.86)
```
"""
PCA(; maxdim=nothing, pratio=0.99) = 
  ZScore() → EigenAnalysis(:V, maxdim, pratio)

"""
    DRS(; maxdim=nothing, pratio=0.99)

The DRS transform is a shortcut for
`ZScore() → EigenAnalysis(:VD; maxdim, pratio)`.

See also: [`ZScore`](@ref), [`EigenAnalysis`](@ref).

# Examples

```julia
DRS(maxdim=3)
DRS(pratio=0.87)
DRS(maxdim=3, pratio=0.87)
```
"""
DRS(; maxdim=nothing, pratio=0.99) = 
  ZScore() → EigenAnalysis(:VD, maxdim, pratio)

"""
    SDS(; maxdim=nothing, pratio=0.99)

The SDS transform is a shortcut for
`ZScore() → EigenAnalysis(:VDV; maxdim, pratio)`.

See also: [`ZScore`](@ref), [`EigenAnalysis`](@ref).

# Examples

```julia
SDS()
SDS(maxdim=4)
SDS(pratio=0.88)
SDS(maxdim=4, pratio=0.88)
```
"""
SDS(; maxdim=nothing, pratio=0.99) = 
  ZScore() → EigenAnalysis(:VDV, maxdim, pratio)

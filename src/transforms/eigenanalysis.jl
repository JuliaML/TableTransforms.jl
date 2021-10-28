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

The `:V` projection, also called PCA transform, use the covariance matrix,
performs the eigenvalues decomposition and take the eigenvectors matrix to
project the data on the directions that make the data uncorrelated.

The `:VD` projection, also known as DRS transform, is closely related to PCA
transform, the difference between PCA and DRS is the additional step that multiplies
the eigenvectors matrix by the squared inverse of the eigenvalues diagonal
matrix, then transform the data, making it uncorrelated and having variance one.

The `:VDV` projection, or SDS transform, is also related to PCA transform,
making the data uncorrelated and having variance one. The difference between DRS
transform and SDS transform is that the data is projected back to the basis
of the original variables using the Vᵀ matrix.
"""
struct EigenAnalysis <: Transform
  proj::Symbol
end

isrevertible(::Type{EigenAnalysis}) = true

function pcaproj(λ, V)
  V, transpose(V)
end

function drsproj(λ, V)
  Λ = Diagonal(sqrt.(λ))
  S = V * inv(Λ)
  S, inv(S)
end

function sdsproj(λ, V)
  Λ = Diagonal(sqrt.(λ))
  S = V * inv(Λ) * transpose(V)
  S, inv(S)
end

function perform(transform::EigenAnalysis, λ, V)
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
  Γ, Γ⁻¹ = perform(transform, λ, V)
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
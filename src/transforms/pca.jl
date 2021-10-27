# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    PCA()

The PCA transform returns a table with uncorrelated variables.
"""
struct PCA <: Transform end

isrevertible(::Type{PCA}) = true

function apply(::PCA, table)
  # sanity checks
  sch = schema(table)
  names = sch.names
  types = sch.scitypes
  @assert all(T <: Continuous for T in types) "columns must hold continuous variables"

  X = Tables.matrix(table)
  Σ = cov(X)
  V = eigvecs(Σ)
  Y = X * V

  # table with transformed columns
  𝒯 = (; zip(names, eachcol(Y))...)
  newtable = 𝒯 |> Tables.materializer(table)

  newtable, V'
end

function revert(::PCA, newtable, cache)
  # sanity checks
  sch = schema(newtable)
  names = sch.names
  types = sch.scitypes
  @assert all(T <: Continuous for T in types) "columns must hold continuous variables"

  Y = Tables.matrix(newtable)
  X = Y * cache

  # table with original columns
  𝒯 = (; zip(names, eachcol(X))...)
  𝒯 |> Tables.materializer(newtable)
end
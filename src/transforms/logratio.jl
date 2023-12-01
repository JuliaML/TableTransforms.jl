# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    LogRatio

Parent type of all log-ratio transforms.

See also [`ALR`](@ref), [`CLR`](@ref), [`ILR`](@ref).
"""
abstract type LogRatio <: StatelessFeatureTransform end

# log-ratio transform interface
function refvar end
function newvars end
function applymatrix end
function revertmatrix end

isrevertible(::Type{<:LogRatio}) = true

assertions(::LogRatio) = [SciTypeAssertion(scitype=Continuous)]

function applyfeat(transform::LogRatio, feat, prep)
  cols = Tables.columns(feat)
  onames = Tables.columnnames(cols)
  varnames = collect(onames)

  # reference variable
  rvar = refvar(transform, varnames)
  _assert(rvar ∈ varnames, "invalid reference variable")
  rind = findfirst(==(rvar), varnames)

  # permute columns if necessary
  perm = rind ≠ lastindex(varnames)
  pfeat = if perm
    popat!(varnames, rind)
    push!(varnames, rvar)
    feat |> Select(varnames)
  else
    feat
  end

  # apply transform
  X = Tables.matrix(pfeat)
  Y = applymatrix(transform, X)

  # new variable names
  newnames = newvars(transform, varnames)

  # return same table type
  𝒯 = (; zip(newnames, eachcol(Y))...)
  newfeat = 𝒯 |> Tables.materializer(feat)

  newfeat, (rind, perm, onames)
end

function revertfeat(transform::LogRatio, newfeat, fcache)
  # revert transform
  Y = Tables.matrix(newfeat)
  X = revertmatrix(transform, Y)

  # retrieve cache
  rind, perm, onames = fcache

  # revert the permutation if necessary
  if perm
    n = length(onames)
    inds = collect(1:(n - 1))
    insert!(inds, rind, n)
    X = X[:, inds]
  end

  # return same table type
  𝒯 = (; zip(onames, eachcol(X))...)
  𝒯 |> Tables.materializer(newfeat)
end

# ----------------
# IMPLEMENTATIONS
# ----------------

include("logratio/alr.jl")
include("logratio/clr.jl")
include("logratio/ilr.jl")

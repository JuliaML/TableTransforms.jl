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
function oldvars end
function applymatrix end
function revertmatrix end

isrevertible(::Type{<:LogRatio}) = true

assertions(::LogRatio) = [SciTypeAssertion{Continuous}()]

function applyfeat(transform::LogRatio, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols) |> collect

  # reference variable
  rvar = refvar(transform, names)
  @assert rvar ∈ names "invalid reference variable"
  rind = findfirst(==(rvar), names)

  # permute columns if necessary
  perm = rind ≠ lastindex(names)
  pfeat = if perm
    popat!(names, rind)
    push!(names, rvar)
    feat |> Select(names)
  else
    feat
  end

  # apply transform
  X = Tables.matrix(pfeat)
  Y = applymatrix(transform, X)

  # new variable names
  newnames = newvars(transform, names)

  # return same table type
  𝒯 = (; zip(newnames, eachcol(Y))...)
  newfeat = 𝒯 |> Tables.materializer(feat)

  newfeat, (rvar, rind, perm)
end

function revertfeat(transform::LogRatio, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)

  # revert transform
  Y = Tables.matrix(newfeat)
  X = revertmatrix(transform, Y)

  # retrieve cache
  rvar, rind, perm = fcache

  # original variable names
  onames = oldvars(transform, names, rvar)

  # revert the permutation if necessary
  if perm
    n = length(onames)
    inds = collect(1:(n - 1))
    insert!(inds, rind, n)
    onames = onames[inds]
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

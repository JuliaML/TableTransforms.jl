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

assertions(::LogRatio) = [scitypeassert(Continuous)]

function applyfeat(transform::LogRatio, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  vars = collect(names)

  # perform closure for full revertibility
  cfeat, ccache = apply(Closure(), feat)

  # reference variable
  rvar = refvar(transform, vars)
  _assert(rvar ∈ vars, "invalid reference variable")

  # reference index
  rind = findfirst(==(rvar), vars)

  # permute columns if necessary
  perm = rind ≠ lastindex(vars)
  pfeat = if perm
    popat!(vars, rind)
    push!(vars, rvar)
    cfeat |> Select(vars)
  else
    cfeat
  end

  # apply transform
  X = Tables.matrix(pfeat)
  Y = applymatrix(transform, X)

  # new variable names
  newnames = newvars(transform, vars)

  # return same table type
  𝒯 = (; zip(newnames, eachcol(Y))...)
  newfeat = 𝒯 |> Tables.materializer(feat)

  newfeat, (ccache, perm, rind, vars)
end

function revertfeat(transform::LogRatio, newfeat, fcache)
  # retrieve cache
  ccache, perm, rind, vars = fcache

  # revert transform
  Y = Tables.matrix(newfeat)
  X = revertmatrix(transform, Y)
  pfeat = (; zip(vars, eachcol(X))...)

  # revert the permutation if necessary
  cfeat = if perm
    n = length(vars)
    inds = collect(1:(n - 1))
    insert!(inds, rind, n)
    pfeat |> Select(inds)
  else
    pfeat
  end

  # revert closure for full revertibility
  𝒯 = revert(Closure(), cfeat, ccache)

  # return same table type
  𝒯 |> Tables.materializer(newfeat)
end

# ----------------
# IMPLEMENTATIONS
# ----------------

include("logratio/alr.jl")
include("logratio/clr.jl")
include("logratio/ilr.jl")


# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    Closure()

The transform that applies the closure operation (i.e. `x ./ sum(x)`),
to all rows of the input table. The rows of the output table sum to one.

See also [`Remainder`](@ref).
"""
struct Closure <: StatelessFeatureTransform end

isrevertible(::Type{Closure}) = true

assertions(::Closure) = [SciTypeAssertion{Continuous}()]

function applyfeat(::Closure, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)

  # table as matrix and get the sum acros dims 2
  X = Tables.matrix(feat)
  S = sum(X, dims=2)

  # divides each row by its sum (closure operation)
  Z = X ./ S

  # table with the old columns and the new values
  𝒯 = (; zip(names, eachcol(Z))...)
  newfeat = 𝒯 |> Tables.materializer(feat)

  newfeat, S
end

function revertfeat(::Closure, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)

  # table as matrix
  Z = Tables.matrix(newfeat)

  # retrieve cache
  S = fcache

  # undo operation
  X = Z .* S

  # table with original columns
  𝒯 = (; zip(names, eachcol(X))...)
  𝒯 |> Tables.materializer(newfeat)
end

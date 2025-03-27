
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

assertions(::Closure) = [scitypeassert(Continuous)]

function applyfeat(::Closure, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)

  # convert table to matrix
  X = Tables.matrix(feat)

  # divide each row by its sum (closure operation)
  S = sum(X, dims=2)
  Z = X ./ S

  # table with the old columns and the new values
  𝒯 = (; zip(names, eachcol(Z))...)
  newfeat = 𝒯 |> Tables.materializer(feat)

  newfeat, S
end

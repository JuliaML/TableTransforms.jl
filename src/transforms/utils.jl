# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

zscore(x, μ, σ) = iszero(σ) ? fill(zero(μ), length(x)) : @. (x - μ) / σ

revzscore(y, μ, σ) = iszero(σ) ? fill(μ, length(y)) : @. σ * y + μ

_assert(cond, msg) = cond || throw(AssertionError(msg))

function scitypeassert(S, selector=AllSelector())
  Assert(
    selector,
    cond=x -> elscitype(x) <: S,
    msg=nm -> "the elements of the column '$nm' are not of scientific type $S"
  )
end

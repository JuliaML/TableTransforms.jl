# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

zscore(x, μ, σ) = @. (x - μ) / σ

revzscore(y, μ, σ) = @. σ * y + μ

_assert(cond, msg) = cond || throw(AssertionError(msg))

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    ZScore()

The z-score (a.k.a. normal score) of `x` with mean `μ` and
standard deviation `σ` is the value `(x .- μ) ./ σ`.
"""
struct ZScore <: Colwise end

isrevertible(::Type{ZScore}) = true

function colcache(::ZScore, x)
  μ = mean(x)
  σ = std(x, mean=μ)
  (μ=μ, σ=σ)
end

colapply(::ZScore, x, c)  = @. (x - c.μ) / c.σ

colrevert(::ZScore, y, c) = @. c.σ * y + c.μ
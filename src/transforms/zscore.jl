# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    ZScore()

Applies the z-score transform (a.k.a. normal score) in all table columns.
The z-score transform of the column `x`, with mean `μ` and standard deviation `σ`,
is defined by `(x .- μ) ./ σ`.
"""
struct ZScore <: Colwise end

assertions(::Type{ZScore}) = [assert_continuous]

isrevertible(::Type{ZScore}) = true

function colcache(::ZScore, x)
  μ = mean(x)
  σ = std(x, mean=μ)
  (μ=μ, σ=σ)
end

colapply(::ZScore, x, c)  = @. (x - c.μ) / c.σ

colrevert(::ZScore, y, c) = @. c.σ * y + c.μ

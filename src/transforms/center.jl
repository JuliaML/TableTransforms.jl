# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Center()

Applies the center transform to all columns of the table.
The center transform of the column `x`, with mean `μ`,
is defined by `x .- μ`.
"""
struct Center <: Colwise end

assertions(::Type{Center}) = [assert_continuous]

isrevertible(::Type{Center}) = true

colcache(::Center, x) = mean(x)

colapply(::Center, x, μ)  = @. x - μ

colrevert(::Center, y, μ) = @. y + μ

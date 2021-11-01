# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Center()

The transform that removes the mean of the variables.
"""
struct Center <: Colwise end

isrevertible(::Type{Center}) = true

colcache(::Center, x) = mean(x)

colapply(::Center, x, μ)  = @. x - μ

colrevert(::Center, y, μ) = @. y + μ
# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Center(skipmissing=true)

The transform that removes the mean of the variables. Skips the missing values by default.
"""

struct Center <: Colwise
    skipmissing::Bool
end

Center(;skipmissing=true) = Center(skipmissing)

assertions(::Type{Center}) = [assert_continuous_or_missing]

isrevertible(::Type{Center}) = true

function colcache(transform::Center, x)
    if transform.skipmissing
        mean(skipmissing(x))
    else
        mean(x)
    end
end

colapply(::Center, x, μ)  = @. x - μ

colrevert(::Center, y, μ) = @. y + μ

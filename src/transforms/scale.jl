# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Scale(; low=0.25, high=0.75)

The scale transform of `x` is the value `(x .- xl) ./ (xh .- xl))`
where `xl = quantile(x, low)` and `xh = quantile(x, high)`.
"""
struct Scale <: Colwise
  low::Float64
  high::Float64
end

Scale(; low=0.25, high=0.75) = Scale(low, high)

isrevertible(::Type{Scale}) = true

function colcache(transform::Scale, x)
  levels = (transform.low, transform.high)
  xl, xh = quantile(x, levels)
  (xl=xl, xh=xh)
end

colapply(::Scale, x, c)  = @. (x - c.xl) / (c.xh - c.xl)

colrevert(::Scale, y, c) = @. (c.xh - c.xl) * y + c.xl

"""
    MinMax()

The transform that is equivalent to `Scale(low=0, high=1)`.
"""
MinMax() = Scale(low=0.0, high=1.0)

"""
    Interquartile()

The transform that is equivalent to `Scale(low=0.25, high=0.75)`.
"""
Interquartile() = Scale(low=0.25, high=0.75)

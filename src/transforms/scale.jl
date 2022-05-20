# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Scale(; low=0.25, high=0.75)

Applies the scale transform to all columns of the table.
The scale transform of the column `x` is defined by `(x .- xl) ./ (xh - xl)`,
where `xl = quantile(x, low)` and `xh = quantile(x, high)`.

# Examples

```julia
Scale()
Scale(low=0, high=1)
Scale(low=0.3, high=0.7)
```

## Notes

* The `low` and `high` values are restricted to the interval [0, 1].
"""
struct Scale{T<:Real} <: Colwise
  low::T
  high::T

  function Scale(low::T, high::T) where {T<:Real}
    @assert 0 ≤ low ≤ high ≤ 1 "invalid quantiles"
    new{T}(low, high)
  end
end

Scale(low::Real, high::Real) = Scale(promote(low, high)...)

Scale(; low=0.25, high=0.75) = Scale(low, high)

assertions(::Type{<:Scale}) = [assert_continuous]

isrevertible(::Type{<:Scale}) = true

function colcache(transform::Scale, x)
  levels = (transform.low, transform.high)
  xl, xh = quantile(x, levels)
  xl == xh && ((xl, xh) = (zero(xl), one(xh)))
  (xl=xl, xh=xh)
end

colapply(::Scale, x, c)  = @. (x - c.xl) / (c.xh - c.xl)

colrevert(::Scale, y, c) = @. (c.xh - c.xl) * y + c.xl

"""
    MinMax()

The transform that is equivalent to `Scale(low=0, high=1)`.

See also [`Scale`](@ref).
"""
MinMax() = Scale(low=0, high=1)

"""
    Interquartile()

The transform that is equivalent to `Scale(low=0.25, high=0.75)`.

See also [`Scale`](@ref).
"""
Interquartile() = Scale(low=0.25, high=0.75)

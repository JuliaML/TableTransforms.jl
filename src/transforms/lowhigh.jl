# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    LowHigh(; low=0.25, high=0.75)

Transforms a column `x` into `(x .- xl) ./ (xh - xl)`,
where `xl = quantile(x, low)` and `xh = quantile(x, high)`.

    LowHigh(col₁, col₂, ..., colₙ; low=0.25, high=0.75)
    LowHigh([col₁, col₂, ..., colₙ]; low=0.25, high=0.75)
    LowHigh((col₁, col₂, ..., colₙ); low=0.25, high=0.75)

Applies the transform to columns `col₁`, `col₂`, ..., `colₙ`.

    LowHigh(regex; low=0.25, high=0.75)

Applies the transform to columns that match with `regex`.

## Examples

```julia
LowHigh()
LowHigh(low=0, high=1)
LowHigh(low=0.3, high=0.7)
LowHigh(1, 3, 5, low=0, high=1)
LowHigh([:a, :c, :e], low=0.3, high=0.7)
LowHigh(("a", "c", "e"), low=0.25, high=0.75)
LowHigh(r"[ace]", low=0.3, high=0.7)
```
"""
struct LowHigh{S<:ColumnSelector,T} <: ColwiseFeatureTransform
  selector::S
  low::T
  high::T

  function LowHigh(selector::S, low::T, high::T) where {S<:ColumnSelector,T}
    _assert(0 ≤ low ≤ high ≤ 1, "invalid quantiles")
    new{S,T}(selector, low, high)
  end
end

LowHigh(selector::ColumnSelector, low, high) = LowHigh(selector, promote(low, high)...)

LowHigh(; low=0.25, high=0.75) = LowHigh(AllSelector(), low, high)
LowHigh(cols; low=0.25, high=0.75) = LowHigh(selector(cols), low, high)
LowHigh(cols::C...; low=0.25, high=0.75) where {C<:Column} = LowHigh(selector(cols), low, high)

assertions(transform::LowHigh) = [scitypeassert(Continuous, transform.selector)]

parameters(transform::LowHigh) = (low=transform.low, high=transform.high)

isrevertible(::Type{<:LowHigh}) = true

function colcache(transform::LowHigh, x)
  low = convert(eltype(x), transform.low)
  high = convert(eltype(x), transform.high)
  xl, xh = quantile(x, (low, high))
  xl == xh && ((xl, xh) = (zero(xl), one(xh)))
  (; xl, xh)
end

colapply(::LowHigh, x, c) = @. (x - c.xl) / (c.xh - c.xl)

colrevert(::LowHigh, y, c) = @. (c.xh - c.xl) * y + c.xl

"""
    MinMax()

Applies the MinMax transform to all columns of the table.
The MinMax transform is equivalent to `LowHigh(low=0, high=1)`.

    MinMax(col₁, col₂, ..., colₙ)
    MinMax([col₁, col₂, ..., colₙ])
    MinMax((col₁, col₂, ..., colₙ))

Applies the MinMax transform on columns `col₁`, `col₂`, ..., `colₙ`.

    MinMax(regex)

Applies the MinMax transform on columns that match with `regex`.

## Examples

```julia
MinMax(1, 3, 5)
MinMax([:a, :c, :e])
MinMax(("a", "c", "e"))
MinMax(r"[ace]")
```

See also [`LowHigh`](@ref).
"""
MinMax(args...) = LowHigh(args...; low=0, high=1)

"""
    Interquartile()

Applies the Interquartile transform to all columns of the table.
The Interquartile transform is equivalent to `LowHigh(low=0.25, high=0.75)`.

    Interquartile(col₁, col₂, ..., colₙ)
    Interquartile([col₁, col₂, ..., colₙ])
    Interquartile((col₁, col₂, ..., colₙ))

Applies the Interquartile transform on columns `col₁`, `col₂`, ..., `colₙ`.

    Interquartile(regex)

Applies the Interquartile transform on columns that match with `regex`.

## Examples

```julia
Interquartile(1, 3, 5)
Interquartile([:a, :c, :e])
Interquartile(("a", "c", "e"))
Interquartile(r"[ace]")
```

See also [`LowHigh`](@ref).
"""
Interquartile(args...) = LowHigh(args...; low=0.25, high=0.75)

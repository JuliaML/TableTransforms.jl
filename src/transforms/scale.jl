# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Scale(; low=0.25, high=0.75)

Applies the Scale transform to all columns of the table.
The scale transform of the column `x` is defined by `(x .- xl) ./ (xh - xl)`,
where `xl = quantile(x, low)` and `xh = quantile(x, high)`.

    Scale(col₁, col₂, ..., colₙ; low=0.25, high=0.75)
    Scale([col₁, col₂, ..., colₙ]; low=0.25, high=0.75)
    Scale((col₁, col₂, ..., colₙ); low=0.25, high=0.75)

Applies the Scale transform on columns `col₁`, `col₂`, ..., `colₙ`.

    Scale(regex; low=0.25, high=0.75)

Applies the Scale transform on columns that match with `regex`.

# Examples

```julia
Scale()
Scale(low=0, high=1)
Scale(low=0.3, high=0.7)
Scale(1, 3, 5, low=0, high=1)
Scale([:a, :c, :e], low=0.3, high=0.7)
Scale(("a", "c", "e"), low=0.25, high=0.75)
Scale(r"[ace]", low=0.3, high=0.7)
```

## Notes

* The `low` and `high` values are restricted to the interval [0, 1].
"""
struct Scale{S<:ColSpec,T<:Real} <: ColwiseFeatureTransform
  colspec::S
  low::T
  high::T

  function Scale(colspec::S, low::T, high::T) where {S<:ColSpec,T<:Real}
    @assert 0 ≤ low ≤ high ≤ 1 "invalid quantiles"
    new{S,T}(colspec, low, high)
  end
end

Scale(colspec::ColSpec, low::Real, high::Real) = 
  Scale(colspec, promote(low, high)...)

Scale(; low=0.25, high=0.75) = Scale(AllSpec(), low, high)
Scale(spec; low=0.25, high=0.75) = Scale(colspec(spec), low, high)
Scale(cols::C...; low=0.25, high=0.75) where {C<:Col} = 
  Scale(colspec(cols), low, high)

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

Applies the MinMax transform to all columns of the table.
The MinMax transform is equivalent to `Scale(low=0, high=1)`.

    MinMax(col₁, col₂, ..., colₙ)
    MinMax([col₁, col₂, ..., colₙ])
    MinMax((col₁, col₂, ..., colₙ))

Applies the MinMax transform on columns `col₁`, `col₂`, ..., `colₙ`.

    MinMax(regex)

Applies the MinMax transform on columns that match with `regex`.

# Examples

```julia
MinMax(1, 3, 5)
MinMax([:a, :c, :e])
MinMax(("a", "c", "e"))
MinMax(r"[ace]")
```

See also [`Scale`](@ref).
"""
MinMax(args...) = Scale(args...; low=0, high=1)

"""
    Interquartile()

Applies the Interquartile transform to all columns of the table.
The Interquartile transform is equivalent to `Scale(low=0.25, high=0.75)`.

    Interquartile(col₁, col₂, ..., colₙ)
    Interquartile([col₁, col₂, ..., colₙ])
    Interquartile((col₁, col₂, ..., colₙ))

Applies the Interquartile transform on columns `col₁`, `col₂`, ..., `colₙ`.

    Interquartile(regex)

Applies the Interquartile transform on columns that match with `regex`.

# Examples

```julia
Interquartile(1, 3, 5)
Interquartile([:a, :c, :e])
Interquartile(("a", "c", "e"))
Interquartile(r"[ace]")
```

See also [`Scale`](@ref).
"""
Interquartile(args...) = Scale(args...; low=0.25, high=0.75)

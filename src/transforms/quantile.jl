# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Quantile(; dist=Normal())

The quantile transform to a given `distribution`.

    Quantile(col₁, col₂, ..., colₙ; dist=Normal())
    Quantile([col₁, col₂, ..., colₙ]; dist=Normal())
    Quantile((col₁, col₂, ..., colₙ); dist=Normal())

Applies the Quantile transform on columns `col₁`, `col₂`, ..., `colₙ`.

    Quantile(regex; dist=Normal())

Applies the Quantile transform on columns that match with `regex`.

# Examples

```julia
using Distributions

Quantile()
Quantile(dist=Normal())
Quantile(1, 3, 5, dist=Beta())
Quantile([:a, :c, :e], dist=Gamma())
Quantile(("a", "c", "e"), dist=Beta())
Quantile(r"[ace]", dist=Normal())
```
"""
struct Quantile{S<:ColSpec,D} <: ColwiseFeatureTransform
  colspec::S
  dist::D
end

Quantile(; dist=Normal()) = Quantile(AllSpec(), dist)
Quantile(spec; dist=Normal()) = Quantile(colspec(spec), dist)
Quantile(cols::C...; dist=Normal()) where {C<:Col} = 
  Quantile(colspec(cols), dist)

assertions(::Type{<:Quantile}) = [assert_continuous]

isrevertible(::Type{<:Quantile}) = true

colcache(::Quantile, x) = EmpiricalDistribution(x)

function colapply(transform::Quantile, x, c)
  origin, target = c, transform.dist
  qqtransform(x, origin, target)
end

function colrevert(transform::Quantile, y, c)
  origin, target = transform.dist, c
  qqtransform(y, origin, target)
end

# transform samples from original to target distribution
function qqtransform(samples, origin, target)
  # avoid evaluating the quantile at 0 or 1
  T = eltype(samples)
  low = zero(T) + T(0.001)
  high = one(T) - T(0.001)
  map(samples) do sample
    prob = cdf(origin, sample)
    quantile(target, clamp(prob, low, high))
  end
end

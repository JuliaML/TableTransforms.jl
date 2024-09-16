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
struct Quantile{S<:ColumnSelector,D} <: ColwiseFeatureTransform
  selector::S
  dist::D
end

Quantile(; dist=Normal()) = Quantile(AllSelector(), dist)
Quantile(cols; dist=Normal()) = Quantile(selector(cols), dist)
Quantile(cols::C...; dist=Normal()) where {C<:Column} = Quantile(selector(cols), dist)

assertions(transform::Quantile) = [scitypeassert(Continuous, transform.selector)]

parameters(transform::Quantile) = (; dist=transform.dist)

isrevertible(::Type{<:Quantile}) = true

function colcache(::Quantile, x)
  s = qsmooth(x)
  d = EmpiricalDistribution(s)
  d, s
end

function colapply(transform::Quantile, x, c)
  d, s = c
  origin, target = d, transform.dist
  qtransform(s, origin, target)
end

function colrevert(transform::Quantile, y, c)
  d, _ = c
  origin, target = transform.dist, d
  qtransform(y, origin, target)
end

# transform samples from original to target distribution
function qtransform(samples, origin, target)
  # avoid evaluating the quantile at 0 or 1
  pmin = 0.0 + 1e-3
  pmax = 1.0 - 1e-3
  map(samples) do sample
    prob = cdf(origin, sample)
    quantile(target, clamp(prob, pmin, pmax))
  end
end

# helper function that replaces repated values
# by an increasing sequence of values between
# the previous and the next non-repated value
function qsmooth(values)
  permut = sortperm(values)
  sorted = float.(values[permut])
  bounds = findall(>(zero(eltype(sorted))), diff(sorted))
  if !isempty(bounds)
    i = 1
    j = first(bounds)
    qlinear!(sorted, i, j, sorted[j], sorted[j + 1])
    for k in 1:(length(bounds) - 1)
      i = bounds[k] + 1
      j = bounds[k + 1]
      qlinear!(sorted, i, j, sorted[i - 1], sorted[j])
    end
    i = last(bounds) + 1
    j = length(sorted)
    qlinear!(sorted, i, j, sorted[i - 1], sorted[j])
  end
  sorted[sortperm(permut)]
end

function qlinear!(x, i, j, l, u)
  if i < j
    for k in i:j
      x[k] = (u - l) * (k - i) / (j - i) + l
    end
  end
end

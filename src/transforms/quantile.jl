# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Quantile(distribution=Normal())

The quantile transform to a given `distribution`.
"""
struct Quantile{D} <: Colwise
  dist::D
end

Quantile() = Quantile(Normal())

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
  map(samples) do sample
    prob = cdf(origin, sample)
    quantile(target, prob - eps())
  end
end
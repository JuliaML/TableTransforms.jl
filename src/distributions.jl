# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    EmpiricalDistribution(values)

An empirical distribution holding continuous values.
"""
struct EmpiricalDistribution{T} <: ContinuousUnivariateDistribution
  values::Vector{T}

  function EmpiricalDistribution{T}(values) where {T}
    _assert(!isempty(values), "values must be provided")
    new(sort(values))
  end
end

EmpiricalDistribution(values) = EmpiricalDistribution{eltype(values)}(values)

quantile(d::EmpiricalDistribution, p::Real) = quantile(d.values, p, sorted=true)

function cdf(d::EmpiricalDistribution{T}, x::T) where {T}
  v = d.values
  n = length(v)

  head, mid, tail = 1, 1, n
  while tail - head > 1
    mid = (head + tail) ÷ 2
    if x < v[mid]
      tail = mid
    else
      head = mid
    end
  end

  l, u = v[head], v[tail]

  if x < l
    return T(0)
  elseif x > u
    return T(1)
  else
    if l == u
      return tail / n
    else
      pl, pu = head / n, tail / n
      return (pu - pl) * (x - l) / (u - l) + pl
    end
  end
end

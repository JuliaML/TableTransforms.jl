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
    new(_smooth(values))
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

# helper function that replaces repated values
# by an increasing sequence of values between
# the previous and the next non-repated value
function _smooth(values)
  sorted = float.(sort(values))
  bounds = findall(>(0), diff(sorted))
  if !isempty(bounds)
    i = 1
    j = first(bounds)
    _linear!(sorted, i, j, sorted[j], sorted[j + 1])
    for k in 1:length(bounds)-1
      i = bounds[k] + 1
      j = bounds[k + 1]
      _linear!(sorted, i, j, sorted[i - 1], sorted[j])
    end
    i = last(bounds) + 1
    j = length(sorted)
    _linear!(sorted, i, j, sorted[i - 1], sorted[j])
  end
  sorted
end

function _linear!(x, i, j, l, u)
  if i < j
    for k in i:j
      x[k] = (u - l) * (k - i) / (j - i) + l
    end
  end
end

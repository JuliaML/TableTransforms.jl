# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Quantile(distribution=Normal())

The quantile transform to a given `distribution`.
"""
struct Quantile{D} <: Transform
  dist::D
end

Quantile() = Quantile(Normal())

isrevertible(::Type{<:Quantile}) = true

function apply(transform::Quantile, table)
  assert_continuous(table)
  colwise(table) do x
    origin = EmpiricalDistribution(x)
    target = transform.dist
    y = qqtransform(x, origin, target)
    y, origin
  end
end

function revert(transform::Quantile, newtable, cache)
  # transformed columns
  names = Tables.columnnames(newtable)
  cols  = Tables.columns(newtable)

  # original columns
  oldcols = map(1:length(names)) do i
    samples = Tables.getcolumn(cols, i)
    origin  = transform.dist
    target  = cache[i]
    qqtransform(samples, origin, target)
  end

  # table with original columns
  𝒯 = (; zip(names, oldcols)...)
  𝒯 |> Tables.materializer(newtable)
end

# transform samples from original to target distribution
function qqtransform(samples, origin, target)
  map(samples) do sample
    prob = cdf(origin, sample)
    quantile(target, prob - eps())
  end
end
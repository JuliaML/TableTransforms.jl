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
  # sanity checks
  assert_continuous(table)

  # variable names
  names = schema(table).names

  # transformed samples and original distributions
  vals = map(names) do name
    samples = Tables.getcolumn(table, name)
    origin  = EmpiricalDistribution(samples)
    target  = transform.dist
    transf  = _qtransform(samples, origin, target)
    transf, origin
  end

  # table with normal scores
  𝒯 = (; zip(names, first.(vals))...)
  newtable = 𝒯 |> Tables.materializer(table)

  # vector with original distributions
  origindists = last.(vals)

  # return new table and original distributions
  newtable, origindists
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
    _qtransform(samples, origin, target)
  end

  # table with original columns
  𝒯 = (; zip(names, oldcols)...)
  𝒯 |> Tables.materializer(newtable)
end

# transform samples from original to target distribution
function _qtransform(samples, origin, target)
  map(samples) do sample
    prob = cdf(origin, sample)
    quantile(target, prob - eps())
  end
end
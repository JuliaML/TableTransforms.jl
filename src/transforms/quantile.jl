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

isinvertible(::Type{<:Quantile}) = true

function forward(transform::Quantile, table)
  # sanity checks
  sch = schema(table)
  names = sch.names
  types = sch.scitypes
  @assert all(T <: Continuous for T in types) "columns must hold continuous variables"

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

function backward(transform::Quantile, newtable, cache)
  names = Tables.columnnames(newtable)
  @assert length(names) == length(cache) "invalid cache for table"

  # modified columns
  cols = Tables.columns(newtable)

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
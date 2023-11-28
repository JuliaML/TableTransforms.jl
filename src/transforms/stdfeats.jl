# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    StdFeats()

Standardizes the columns of the table based on data science traits:

* `Continuous`: `ZScore`
* `Categorical`: `Identity`
* `Unknown`: `Identity`
"""
struct StdFeats <: StatelessFeatureTransform end

isrevertible(::Type{StdFeats}) = true

_stdfun(x) = _stdfun(elscitype(x), x)
_stdfun(::Type, x) = identity, identity
function _stdfun(::Type{Continuous}, x)
  μ = mean(x)
  σ = std(x, mean=μ)
  stdfun = x -> zscore(x, μ, σ)
  revfun = y -> revzscore(y, μ, σ)
  stdfun, revfun
end

function applyfeat(::StdFeats, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)

  tuples = map(names) do name
    x = Tables.getcolumn(cols, name)
    stdfun, revfun = _stdfun(x)
    stdfun(x), revfun
  end

  columns = first.(tuples)
  fcache = last.(tuples)

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)

  newfeat, fcache
end

function revertfeat(::StdFeats, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)

  columns = map(names, fcache) do name, revfun
    y = Tables.getcolumn(cols, name)
    revfun(y)
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

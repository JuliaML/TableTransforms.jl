const SCALES = [:quantile, :linear]

"""
    Indicator(col; k=10, scale=:quantile, categ=false)

Transforms continuous variable into `k` indicator variables defined by
half-intervals of `col` values in a given `scale`. Optionally, specify the `categ`
option to return binary categorical values as opposed to raw 1s and 0s.

Given a sequence of increasing threshold values `t1 < t2 < ... < tk`, the indicator
transform converts a continuous variable `Z` into a sequence of `k` variables
`Z_1 = Z <= t1`, `Z_2 = Z <= t2`, ..., `Z_k = Z <= tk`.

## Scales:

* `:quantile` - threshold values are calculated using the `quantile(Z, p)` function
  with a linear range of probabilities.
* `:linear` - threshold values are calculated using a linear range.

# Examples

```julia
Indicator(1, k=3)
Indicator(:a, k=6, scale=:linear)
Indicator("a", k=9, scale=:linear, categ=true)
```
"""
struct Indicator{S<:SingleColumnSelector} <: StatelessFeatureTransform
  selector::S
  k::Int
  scale::Symbol
  categ::Bool

  function Indicator(selector::S, k, scale, categ) where {S<:SingleColumnSelector}
    if k < 1
      throw(ArgumentError("`k` must be greater than or equal to 1"))
    end

    if scale ∉ SCALES
      throw(ArgumentError("invalid `scale` option, use `:quantile` or `:linear`"))
    end

    new{S}(selector, k, scale, categ)
  end
end

Indicator(col::Column; k=10, scale=:quantile, categ=false) = Indicator(selector(col), k, scale, categ)

assertions(transform::Indicator) = [scitypeassert(Continuous, transform.selector)]

isrevertible(::Type{<:Indicator}) = true

function _intervals(transform::Indicator, x)
  k = transform.k
  ts = if transform.scale === :quantile
    quantile(x, range(0, 1, k + 1))
  else
    range(extrema(x)..., k + 1)
  end
  ts[(begin + 1):end]
end

function applyfeat(transform::Indicator, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols) |> collect
  columns = Any[Tables.getcolumn(cols, nm) for nm in names]

  name = selectsingle(transform.selector, names)
  ind = findfirst(==(name), names)
  x = columns[ind]

  k = transform.k
  ts = _intervals(transform, x)
  tuples = map(1:k) do i
    nm = Symbol("$(name)_$i")
    while nm ∈ names
      nm = Symbol("$(nm)_")
    end
    (nm, x .≤ ts[i])
  end

  newnames = first.(tuples)
  newcolumns = last.(tuples)

  # convert to categorical arrays if necessary
  newcolumns = transform.categ ? categorical.(newcolumns, levels=[false, true]) : newcolumns

  splice!(names, ind, newnames)
  splice!(columns, ind, newcolumns)

  inds = ind:(ind + length(newnames) - 1)

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)
  newfeat, (name, x, inds)
end

function revertfeat(::Indicator, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols) |> collect
  columns = Any[Tables.getcolumn(cols, nm) for nm in names]

  oname, ocolumn, inds = fcache

  splice!(names, inds, [oname])
  splice!(columns, inds, [ocolumn])

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

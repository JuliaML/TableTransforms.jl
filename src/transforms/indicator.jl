const SCALES = [:quantile, :linear]

"""
    Indicator(col; k=10, scale=:quantile, categ=false)

Transforms continuous variable into `k` indicator variables defined by
half-intervals of `col` values in a given `scale`. Optionally, specify the `categ`
option to return binary categorical values as opposed to raw 1s and 0s.

Given a sequence of increasing threshold values `t1 < t2 < ... < tk`, the indicator
transform converts a continuous variable `Z` into a sequence of `k` variables
`I1 = Z <= t1`, `I2 = Z <= t2`, ..., `Ik = Z <= tk`.

# Examples

```julia
Indicator(1, k=3)
Indicator(:a, scale=:linear)
Indicator("a", scale=:linear, categ=true, k=6)
```
"""
struct Indicator{S<:ColSpec} <: StatelessFeatureTransform
  colspec::S
  scale::Symbol
  categ::Bool
  k::Int

  function Indicator(col, scale, categ, k)
    if scale ∉ SCALES
      throw(ArgumentError("invalid `scale` option, use `:quantile` or `:linear`"))
    end

    if k < 1
      throw(ArgumentError("`k` must be greater than or equal to 1"))
    end

    cs = colspec([col])
    new{typeof(cs)}(cs, scale, categ, k)
  end
end

Indicator(col; scale=:quantile, categ=false, k=4) = Indicator(col, scale, categ, k)

assertions(transform::Indicator) = [SciTypeAssertion{Continuous}(transform.colspec)]

isrevertible(::Type{<:Indicator}) = true

function _intervals(transform::Indicator, x)
  k = transform.k
  if transform.scale === :quantile
    p = range(0, 1, k + 1)
    quantile(x, p)
  else
    min, max = extrema(x)
    range(min, max, k + 1)
  end
end

function applyfeat(transform::Indicator, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols) |> collect
  columns = Any[Tables.getcolumn(cols, nm) for nm in names]

  name = choose(transform.colspec, names) |> first
  ind = findfirst(==(name), names)
  x = columns[ind]

  k = transform.k
  ts = _intervals(transform, x)
  tuples = map(1:k) do i
    nm = Symbol("$(name)_$i")
    while nm ∈ names
      nm = Symbol("$(nm)_")
    end
  
    y = if i == 1
      x .≤ ts[i + 1]
    elseif i == k
      x .> ts[i]
    else
      ts[i] .< x .≤ ts[i + 1]
    end

    (nm, y)
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

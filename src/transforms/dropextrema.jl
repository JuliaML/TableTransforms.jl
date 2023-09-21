# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DropExtrema(col; low=0.25, high=0.75)

Drops the rows where the values in the column `col` are outside the interval
`[quantile(col, low), quantile(col, high)]`.

# Examples

```julia
DropExtrema(1)
DropExtrema(:a, low=0.2, high=0.8)
DropExtrema("a", low=0.3, high=0.7)
```
"""
struct DropExtrema{S<:ColSpec,T} <: StatelessFeatureTransform
  colspec::S
  low::T
  high::T

  function DropExtrema(col::Col, low::T, high::T) where {T}
    @assert 0 ≤ low ≤ high ≤ 1 "invalid quantiles"
    cs = colspec(col)
    new{typeof(cs),T}(cs, low, high)
  end
end

DropExtrema(col::Col, low, high) = DropExtrema(col, promote(low, high)...)
DropExtrema(col::Col; low=0.25, high=0.75) = DropExtrema(col, low, high)

isrevertible(::Type{<:DropExtrema}) = true

function preprocess(transform::DropExtrema, table)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  sname = choose(transform.colspec, names) |> first

  x = Tables.getcolumn(cols, sname)
  low = convert(eltype(x), transform.low)
  high = convert(eltype(x), transform.high)
  xl, xh = quantile(x, (low, high))

  ftrans = Filter(row -> xl ≤ row[sname] ≤ xh)
  fprep = preprocess(ftrans, table)
  ftrans, fprep
end

function applyfeat(::DropExtrema, feat, prep)
  ftrans, fprep = prep
  newfeat, ffcache = applyfeat(ftrans, feat, fprep)
  newfeat, (ftrans, ffcache)
end

function revertfeat(::DropExtrema, newfeat, fcache)
  ftrans, ffcache = fcache
  revertfeat(ftrans, newfeat, ffcache)
end

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
struct DropExtrema{S<:SingleColumnSelector,T} <: StatelessFeatureTransform
  selector::S
  low::T
  high::T

  function DropExtrema(selector::S, low::T, high::T) where {S<:SingleColumnSelector,T}
    0 ≤ low ≤ high ≤ 1 || throw(AssertionError("invalid quantiles"))
    new{S,T}(selector, low, high)
  end
end

DropExtrema(selector::SingleColumnSelector, low, high) = DropExtrema(selector, promote(low, high)...)
DropExtrema(col::Column; low=0.25, high=0.75) = DropExtrema(selector(col), low, high)

isrevertible(::Type{<:DropExtrema}) = true

function preprocess(transform::DropExtrema, table)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  sname = selectsingle(transform.selector, names)

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

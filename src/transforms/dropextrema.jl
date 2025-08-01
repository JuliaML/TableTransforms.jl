# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DropExtrema(; low=0.25, high=0.75)

Drops rows where any of the values in all columns
are outside the interval (`[quantile(col, low), quantile(col, high)]`).

    DropExtrema(col₁, col₂, ..., colₙ; low=0.25, high=0.75)
    DropExtrema([col₁, col₂, ..., colₙ]; low=0.25, high=0.75)
    DropExtrema((col₁, col₂, ..., colₙ); low=0.25, high=0.75)

Drops rows where any of the values in columns `col₁`, `col₂`, ..., `colₙ`
are outside the interval.

    DropExtrema(regex; low=0.25, high=0.75)

Drops rows where any of the values in columns that match with `regex`
are outside the interval.

## Examples

```julia
DropExtrema(low=0.3, high=0.7)
DropExtrema(1, low=0.3, high=0.7)
DropExtrema(:a, low=0.2, high=0.8)
DropExtrema("a", low=0.3, high=0.7)
DropExtrema(1, 3, 5, low=0, high=1)
DropExtrema([:a, :c, :e], low=0.3, high=0.7)
DropExtrema(("a", "c", "e"), low=0.25, high=0.75)
DropExtrema(r"[ace]", low=0.3, high=0.7)
```
"""
struct DropExtrema{S<:ColumnSelector,T} <: StatelessFeatureTransform
  selector::S
  low::T
  high::T

  function DropExtrema(selector::S, low::T, high::T) where {S<:ColumnSelector,T}
    _assert(0 ≤ low ≤ high ≤ 1, "invalid quantiles")
    new{S,T}(selector, low, high)
  end
end

DropExtrema(selector::ColumnSelector, low, high) = DropExtrema(selector, promote(low, high)...)

DropExtrema(; low=0.25, high=0.75) = DropExtrema(AllSelector(), low, high)
DropExtrema(cols; low=0.25, high=0.75) = DropExtrema(selector(cols), low, high)
DropExtrema(cols::C...; low=0.25, high=0.75) where {C<:Column} = DropExtrema(selector(cols), low, high)

parameters(transform::DropExtrema) = (low=transform.low, high=transform.high)

function preprocess(transform::DropExtrema, feat)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = transform.selector(names)

  limits = map(snames) do name
    x = Tables.getcolumn(cols, name)
    low = convert(eltype(x), transform.low)
    high = convert(eltype(x), transform.high)
    name => quantile(x, (low, high))
  end

  ftrans = Filter(row -> all(xl ≤ row[nm] ≤ xh for (nm, (xl, xh)) in limits))
  fprep = preprocess(ftrans, feat)
  ftrans, fprep
end

function applyfeat(::DropExtrema, feat, prep)
  ftrans, fprep = prep
  newfeat, _ = applyfeat(ftrans, feat, fprep)
  newfeat, nothing
end

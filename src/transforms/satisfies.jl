# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Satisfies(pred)

Selects the columns where `pred(column)` returns `true`.

## Examples

```julia
Satisfies(allunique)
Satisfies(x -> sum(x) > 100)
Satisfies(x -> eltype(x) <: Integer)
```
"""
struct Satisfies{F} <: StatelessFeatureTransform
  pred::F
end

function applyfeat(transform::Satisfies, feat, prep)
  pred = transform.pred
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = filter(names) do name
    x = Tables.getcolumn(cols, name)
    pred(x)
  end
  strans = Select(snames)
  newfeat, _ = applyfeat(strans, feat, prep)
  newfeat, nothing
end

"""
    Only(S)

Selects the columns that have scientific type `S`.

## Examples

```julia
using DataScienceTraits

Only(Continuous)
```
"""
Only(S::Type{<:SciType}) = Satisfies(x -> elscitype(x) <: S)

"""
    Except(S)

Selects the columns that don't have scientific type `S`.

## Examples

```julia
using DataScienceTraits

Except(Categorical)
```
"""
Except(S::Type{<:SciType}) = Satisfies(x -> !(elscitype(x) <: S))

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Satisfies(pred)

Selects only columns where `pred(column)` returns `true`.

# Examples

```julia
Satisfies(allunique)
Satisfies(x -> sum(x) > 100)
Satisfies(x -> eltype(x) <: Integer)
```
"""
struct Satisfies{F} <: StatelessFeatureTransform
  pred::F
end

isrevertible(::Type{<:Satisfies}) = true

function applyfeat(transform::Satisfies, feat, prep)
  pred = transform.pred
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = filter(names) do name
    x = Tables.getcolumn(cols, name)
    pred(x)
  end
  strans = Select(snames)
  newfeat, sfcache = applyfeat(strans, feat, prep)
  newfeat, (strans, sfcache)
end

function revertfeat(::Satisfies, newfeat, fcache)
  strans, sfcache = fcache
  revertfeat(strans, newfeat, sfcache)
end

"""
    Only(S)

Selects only columns that have scientific type `S`.

# Examples

```julia
import DataScienceTraits as DST
Only(DST.Continuous)
```
"""
Only(S::Type{<:SciType}) = Satisfies(x -> elscitype(x) <: S)

"""
    Except(S)

Selects only columns that does not have scientific type `S`.

# Examples

```julia
import DataScienceTraits as DST
Except(DST.Continuous)
```
"""
Except(S::Type{<:SciType}) = Satisfies(x -> !(elscitype(x) <: S))

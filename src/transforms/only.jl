# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Only(S)

Selects only columns that have scientific type `S`.

# Examples

```julia
import DataScienceTraits as DST
Only(DST.Continuous)
```
"""
struct Only <: StatelessFeatureTransform
  scitype::DataType
  Only(S::Type{<:SciType}) = new(S)
end

isrevertible(::Type{Only}) = true

function applyfeat(transform::Only, feat, prep)
  S = transform.scitype
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = filter(names) do name
    column = Tables.getcolumn(cols, name)
    elscitype(column) <: S
  end
  strans = Select(snames)
  newfeat, sfcache = applyfeat(strans, feat, prep)
  newfeat, (strans, sfcache)
end

function revertfeat(::Only, newfeat, fcache)
  strans, sfcache = fcache
  revertfeat(strans, newfeat, sfcache)
end
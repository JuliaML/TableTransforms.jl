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
struct Only{T<:SciType} <: StatelessFeatureTransform end

Only(::Type{T}) where {T<:SciType} = Only{T}()

Base.show(io::IO, ::Only{T}) where {T<:SciType} = print(io, "Only($T)")
function Base.show(io::IO, ::MIME"text/plain", ::Only{T}) where {T<:SciType}
  println(io, "Only transform")
  print(io, "└─ scitype = $T")
end

isrevertible(::Type{<:Only}) = true

function applyfeat(::Only{T}, feat, prep) where {T<:SciType}
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = filter(names) do name
    column = Tables.getcolumn(cols, name)
    elscitype(column) <: T
  end
  strans = Select(snames)
  newfeat, sfcache = applyfeat(strans, feat, prep)
  newfeat, (strans, sfcache)
end

function revertfeat(::Only, newfeat, fcache)
  strans, sfcache = fcache
  revertfeat(strans, newfeat, sfcache)
end

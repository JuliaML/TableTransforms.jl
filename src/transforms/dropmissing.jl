# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DropMissing()
    DropMissing(:)

Drop all rows with missing values in table.

    DropMissing(col₁, col₂, ..., colₙ)
    DropMissing([col₁, col₂, ..., colₙ])
    DropMissing((col₁, col₂, ..., colₙ))

Drop all rows with missing values in selected columns `col₁`, `col₂`, ..., `colₙ`.

    DropMissing(regex)

Drop all rows with missing values in columns that match with `regex`.

# Examples

```julia
DropMissing()
DropMissing("b", "c", "e")
DropMissing([2, 3, 5])
DropMissing((:b, :c, :e))
DropMissing(r"[bce]")
```

## Notes

* The transform can alter the element type of columns from `Union{Missing,T}` to `T`.
* If the transformed column has only `missing` values, it will be converted to an empty column of type `Any`.
"""
struct DropMissing{S<:ColSpec} <: StatelessFeatureTransform
  colspec::S
end

DropMissing() = DropMissing(AllSpec())
DropMissing(spec) = DropMissing(colspec(spec))
DropMissing(cols::T...) where {T<:Col} = DropMissing(colspec(cols))

isrevertible(::Type{<:DropMissing}) = true

function preprocess(transform::DropMissing, table)
  names = Tables.schema(table).names
  snames = choose(transform.colspec, names)
  ftrans = Filter(row -> all(!ismissing(row[nm]) for nm in snames))
  fprep = preprocess(ftrans, table)
  ftrans, fprep, snames
end

_nonmissing(x) = _nonmissing(eltype(x), x)
_nonmissing(::Type{T}, x) where {T} = x
_nonmissing(::Type{Missing}, x) = []
_nonmissing(::Type{Union{Missing,T}}, x) where {T} = collect(T, x)

function applyfeat(::DropMissing, feat, prep)
  # apply filter transform
  ftrans, fprep, snames = prep
  newfeat, ffcache = applyfeat(ftrans, feat, fprep)

  # drop Missing type
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)
  columns = map(names) do name
    x = Tables.getcolumn(cols, name)
    name ∈ snames ? _nonmissing(x) : x
  end
  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)

  # original column types
  types = Tables.schema(feat).types

  newfeat, (ftrans, ffcache, snames, types)
end

function revertfeat(::DropMissing, newfeat, fcache)
  ftrans, ffcache, snames, types = fcache

  # reintroduce Missing type
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)
  columns = map(types, names) do T, name
    x = Tables.getcolumn(cols, name)
    name ∈ snames ? collect(T, x) : x
  end
  𝒯 = (; zip(names, columns)...)
  ofeat = 𝒯 |> Tables.materializer(newfeat)

  # revert filter transform
  revertfeat(ftrans, ofeat, ffcache)
end

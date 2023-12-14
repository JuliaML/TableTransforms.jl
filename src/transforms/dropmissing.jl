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
struct DropMissing{S<:ColumnSelector} <: StatelessFeatureTransform
  selector::S
end

DropMissing() = DropMissing(AllSelector())
DropMissing(cols) = DropMissing(selector(cols))
DropMissing(cols::C...) where {C<:Column} = DropMissing(selector(cols))

isrevertible(::Type{<:DropMissing}) = false

function preprocess(transform::DropMissing, feat)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = transform.selector(names)
  ftrans = Filter(row -> all(!ismissing(row[nm]) for nm in snames))
  fprep = preprocess(ftrans, feat)
  ftrans, fprep, snames
end

_nonmissing(x) = _nonmissing(eltype(x), x)
_nonmissing(::Type{T}, x) where {T} = x
_nonmissing(::Type{Missing}, x) = []
_nonmissing(::Type{Union{Missing,T}}, x) where {T} = collect(T, x)

function applyfeat(::DropMissing, feat, prep)
  # apply filter transform
  ftrans, fprep, snames = prep
  newfeat, _ = applyfeat(ftrans, feat, fprep)

  # drop Missing type
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)
  columns = map(names) do name
    x = Tables.getcolumn(cols, name)
    name ∈ snames ? _nonmissing(x) : x
  end
  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)

  newfeat, nothing
end

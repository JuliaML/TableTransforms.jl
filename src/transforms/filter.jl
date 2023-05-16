# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Filter(func)

Filters the table returning only the rows where the `func` returns true.

# Examples

```julia
Filter(row -> sum(row) > 10)
Filter(row -> row.a == true && row.b < 30)
```

## Notes

* The schema of the table is preserved by the transform.
"""
struct Filter{F} <: StatelessFeatureTransform
  func::F
end

isrevertible(::Type{<:Filter}) = true

function preprocess(transform::Filter, table)
  # lazy row iterator
  rows = Tables.rows(table)

  # selected indices
  sinds, nrows = Int[], 0
  for (i, row) in enumerate(rows)
    transform.func(row) && push!(sinds, i)
    nrows += 1
  end

  # rejected indices
  rinds = setdiff(1:nrows, sinds)

  sinds, rinds
end

function applyfeat(::Filter, feat, prep)
  # collect all rows
  rows = Tables.rowtable(feat)

  # preprocessed indices
  sinds, rinds = prep

  # select/reject rows
  srows = view(rows, sinds)
  rrows = view(rows, rinds)

  newfeat = srows |> Tables.materializer(feat)

  newfeat, (rinds, rrows)
end

function revertfeat(::Filter, newfeat, fcache)
  # collect all rows
  rows = Tables.rowtable(newfeat)

  rinds, rrows = fcache
  for (i, row) in zip(rinds, rrows)
    insert!(rows, i, row)
  end

  rows |> Tables.materializer(newfeat)
end

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
"""
struct DropMissing{S<:ColSpec} <: StatelessFeatureTransform
  colspec::S
end

DropMissing() = DropMissing(AllSpec())

DropMissing(spec) = DropMissing(colspec(spec))

DropMissing(cols::T...) where {T<:Col} = DropMissing(colspec(cols))

isrevertible(::Type{<:DropMissing}) = true

_ftrans(::DropMissing{AllSpec}, cols) = Filter(row -> all(!ismissing, row))

_ftrans(::DropMissing, cols) = Filter(row -> all(!ismissing, getindex.(Ref(row), cols)))

# nonmissing 
_nonmissing(::Type{T}, x) where {T} = x
_nonmissing(::Type{Union{Missing,T}}, x) where {T} = collect(T, x)
_nonmissing(x) = _nonmissing(eltype(x), x)

function preprocess(transform::DropMissing, table)
  schema = Tables.schema(table)
  names = schema.names
  snames = choose(transform.colspec, names)
  ftrans = _ftrans(transform, snames)
  fprep = preprocess(ftrans, table)
  ftrans, fprep, snames
end

function applyfeat(::DropMissing, feat, prep)
  # apply filter transform
  ftrans, fprep, snames = prep
  newfeat, ffcache = applyfeat(ftrans, feat, fprep)

  # drop Missing type
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)
  ncols = map(names) do n
    x = Tables.getcolumn(cols, n)
    n ∈ snames ? _nonmissing(x) : x
  end
  𝒯 = (; zip(names, ncols)...)
  newfeat = 𝒯 |> Tables.materializer(feat)

  # original column types
  types = Tables.schema(feat).types

  newfeat, (ftrans, ffcache, types)
end

function revertfeat(::DropMissing, newfeat, fcache)
  ftrans, ffcache, types = fcache

  # reintroduce Missing type
  ncols = Tables.columns(newfeat)
  names = Tables.columnnames(ncols)
  ocols = map(zip(types, names)) do (T, n)
    x = Tables.getcolumn(ncols, n)
    collect(T, x)
  end
  𝒯 = (; zip(names, ocols)...)
  otable = 𝒯 |> Tables.materializer(newfeat)

  # revert filter transform
  revertfeat(ftrans, otable, ffcache)
end

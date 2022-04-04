# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Filter(function)

Filters the table returning only the rows where the `function` returns true.
"""
struct Filter{F} <: Stateless
  func::F 
end

isrevertible(::Type{<:Filter}) = true

function apply(transform::Filter, table)
  rows = Tables.rowtable(table)

  # selected and rejected rows/inds
  sinds = findall(transform.func, rows)
  rinds = setdiff(1:length(rows), sinds)
  srows = rows[sinds]
  rrows = rows[rinds]

  newtable = srows |> Tables.materializer(table)
  return newtable, zip(rinds, rrows)
end

function revert(::Filter, newtable, cache)
  rows = Vector{NamedTuple}(Tables.rowtable(newtable))

  for (i, row) in cache
    insert!(rows, i, row)
  end

  rows |> Tables.materializer(newtable)
end

"""
    DropMissing()
    DropMissing(:)

Drop all rows with missing values in table.

    DropMissing(col₁, col₂, ..., colₙ)
    DropMissing([col₁, col₂, ..., colₙ])
    DropMissing((col₁, col₂, ..., colₙ))

Drop all rows with missing values in selects columns `col₁`, `col₂`, ..., `colₙ`.

    DropMissing(regex)

Drop all rows with missing values in columns that match with `regex`.
"""
struct DropMissing{S<:ColSpec} <: Stateless
  colspec::S
end

DropMissing(::Tuple{}) = throw(ArgumentError("Cannot create a DropMissing object with empty tuple."))

DropMissing() = DropMissing(:)

DropMissing(cols::T...) where {T<:ColSelector} =
  DropMissing(cols)

isrevertible(::Type{<:DropMissing}) = true

_ftrans(::DropMissing{Colon}, allcols) =
  allcols, Filter(row -> all(!ismissing, row))

function _ftrans(transform::DropMissing, allcols)
  cols = _filter(transform.colspec, allcols)
  cols, Filter(row -> all(!ismissing, getindex.(Ref(row), cols)))
end

_nonmissing(v) = Vector{nonmissingtype(eltype(v))}(v)

function apply(transform::DropMissing, table)
  allcols = Tables.columnnames(table)
  cols, ftrans = _ftrans(transform, allcols)
  temp, fcache = apply(ftrans, table)
  newcols = [col ∈ cols ? _nonmissing(Tables.getcolumn(temp, col)) : Tables.getcolumn(temp, col)
                        for col in allcols]
  𝒯 = (; zip(allcols, newcols)...)
  newtable = 𝒯 |> Tables.materializer(table)
  newtable, (ftrans, fcache)
end

function revert(::DropMissing, newtable, cache)
  ftrans, fcache = cache
  revert(ftrans, newtable, fcache)
end

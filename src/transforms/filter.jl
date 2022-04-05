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
  rows = Tables.rowtable(newtable)

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

# ftrans
_ftrans(::DropMissing{Colon}, cols) =
  Filter(row -> all(!ismissing, row))

_ftrans(::DropMissing, cols) =
  Filter(row -> all(!ismissing, getindex.(Ref(row), cols)))

# nonmissing 
_nonmissing(::Type{T}, c) where {T} = c
_nonmissing(::Type{Union{Missing,T}}, c) where {T} =
  collect(T, c)

function _nonmissing(columns, col)
  c = Tables.getcolumn(columns, col)
  _nonmissing(eltype(c), c)
end

function _nonmissing(table, cols, allcols)
  columns = Tables.columns(table)
  newcols = [col ∈ cols ? _nonmissing(columns, col) : Tables.getcolumn(columns, col)
             for col in allcols]
  𝒯 = (; zip(allcols, newcols)...)
  𝒯 |> Tables.materializer(table)
end

# reverttypes
function _reverttypes(table, types)
  columns = Tables.columns(table)
  allcols = Tables.columnnames(table)
  newcols = [collect(T, Tables.getcolumn(columns, col)) 
             for (T, col) in zip(types, allcols)]
  𝒯 = (; zip(allcols, newcols)...)
  𝒯 |> Tables.materializer(table)
end

function apply(transform::DropMissing, table)
  allcols = Tables.columnnames(table)
  cols = _filter(transform.colspec, allcols)
  ftrans = _ftrans(transform, cols)
  newtable, fcache = apply(ftrans, table)
  # post-processing
  types = Tables.schema(table).types
  ptable = _nonmissing(newtable, cols, allcols)
  ptable, (ftrans, fcache, types)
end

function revert(::DropMissing, newtable, cache)
  ftrans, fcache, types = cache
  # pre-processing
  ptable = _reverttypes(newtable, types)
  revert(ftrans, ptable, fcache)
end

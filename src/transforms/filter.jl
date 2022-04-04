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

_ftrans(::DropMissing{Colon}, cols) =
  Filter(row -> all(!ismissing, row))

_ftrans(::DropMissing, cols) =
  Filter(row -> all(!ismissing, getindex.(Ref(row), cols)))

function _nonmissing(table, col)
  c = Tables.getcolumn(table, col)
  Vector{nonmissingtype(eltype(c))}(c)
end

function _missing(table, col)
  c = Tables.getcolumn(table, col)
  Vector{Union{Missing,eltype(c)}}(c)
end

function _process(table, cols, func)
  allcols = Tables.columnnames(table)
  newcols = [col ∈ cols ? func(table, col) : Tables.getcolumn(table, col)
             for col in allcols]
  𝒯 = (; zip(allcols, newcols)...)
  𝒯 |> Tables.materializer(table)
end

function apply(transform::DropMissing, table)
  allcols = Tables.columnnames(table)
  cols = _filter(transform.colspec, allcols)
  ftrans = _ftrans(transform, cols)
  newtable, fcache = apply(ftrans, table)
  # post-processing
  ptable = _process(newtable, cols, _nonmissing)
  ptable, (ftrans, fcache, cols)
end

function revert(::DropMissing, newtable, cache)
  ftrans, fcache, cols = cache
  # pre-processing
  ptable = _process(newtable, cols, _missing)
  revert(ftrans, ptable, fcache)
end

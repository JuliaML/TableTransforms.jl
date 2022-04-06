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

_nonmissing(col) = _nonmissing(eltype(col), col)

function apply(transform::DropMissing, table)
  colnames = Tables.columnnames(table)
  select = _filter(transform.colspec, colnames)
  ftrans = _ftrans(transform, select)
  newtable, fcache = apply(ftrans, table)

  # post-processing
  coltable = Tables.columntable(newtable)
  pcolumns = [nm ∈ select ? _nonmissing(col) : col for (nm, col) in pairs(coltable)]
  𝒯 = (; zip(colnames, pcolumns)...)
  ptable = 𝒯 |> Tables.materializer(newtable)

  types = Tables.schema(table).types
  ptable, (ftrans, fcache, types)
end

function revert(::DropMissing, newtable, cache)
  ftrans, fcache, types = cache

  # pre-processing
  colnames = Tables.columnnames(newtable)
  coltable = Tables.columntable(newtable)
  pcolumns = [collect(T, col) for (T, col) in zip(types, coltable)]
  𝒯 = (; zip(colnames, pcolumns)...)
  ptable = 𝒯 |> Tables.materializer(newtable)

  revert(ftrans, ptable, fcache)
end

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

# DropMissing

const VecOrTuple{T} = Union{Vector{T}, NTuple{N, T}} where {T, N}

"""
    DropMissing()

Drop all rows with missing values in table.

    DropMissing(col₁, col₂, ..., colₙ)
    DropMissing([col₁, col₂, ..., colₙ])
    DropMissing((col₁, col₂, ..., colₙ))

Drop all rows with missing values in selects columns `col₁`, `col₂`, ..., `colₙ`.

    DropMissing(regex)

Drop all rows with missing values in columns that match with `regex`.
"""
DropMissing() = Filter(row -> all(!ismissing, row))

DropMissing(cols::VecOrTuple{T}) where {T<:Union{Symbol, Integer}} =
  Filter(row -> all(!ismissing, getindex.(Ref(row), cols)))

DropMissing(cols::VecOrTuple{T}) where {T<:AbstractString} =
  DropMissing(Symbol.(cols))

DropMissing(cols::T...) where {T<:ColSelector} =
  DropMissing(cols)

function DropMissing(regex::Regex)
  Filter() do row
    cols = _select(regex, propertynames(row))
    all(!ismissing, getindex.(Ref(row), cols))
  end
end

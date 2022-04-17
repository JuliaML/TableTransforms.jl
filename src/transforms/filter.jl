# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Filter(function)

Filters the table returning only the rows where the `function` returns true.

# Examples
```julia
T = Filter(row -> sum(row) > 10)
T = Filter(row -> row.a == true && row.b < 30)
```

Note that schema of the new table is the same as the original table:
```julia
julia> table = (a = [1, missing, 2, 3], b = [missing, 1, 2, 3]);

julia> T = Filter(row -> all(!ismissing, row));

julia> newtable, cache = apply(T, table);

julia> newtable
(a = Union{Missing, Int64}[2, 3], b = Union{Missing, Int64}[2, 3])
```
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
The `col` arguments must be the same type and the accepted types 
for `col` arguments are: `Integer`, `Symbol` or `String`.

    DropMissing(regex)

Drop all rows with missing values in columns that match with `regex`.

# Examples
```julia
T = DropMissing()
T = DropMissing("b", "c", "e")
T = DropMissing([2, 3, 5])
T = DropMissing((:b, :c, :e))
T = DropMissing(r"[bce]]")
```

Note that columns affected by DropMissing will have their schema changed:
```julia
julia> table = (a = [1, missing, 2, 3], b = [missing, 1, 2, 3]);

julia> T = DropMissing();

julia> newtable, cache = apply(T, table);

julia> newtable
(a = [2, 3], b = [2, 3])
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

# nonmissing 
_nonmissing(::Type{T}, x) where {T} = x
_nonmissing(::Type{Union{Missing,T}}, x) where {T} = collect(T, x)
_nonmissing(x) = _nonmissing(eltype(x), x)

function apply(transform::DropMissing, table)
  names = Tables.columnnames(table)
  types = Tables.schema(table).types
  snames = choose(transform.colspec, names)
  ftrans = _ftrans(transform, snames)
  newtable, fcache = apply(ftrans, table)

  # post-processing
  cols = Tables.columns(newtable)
  pcols = map(names) do n
    x = Tables.getcolumn(cols, n)
    n ∈ snames ? _nonmissing(x) : x
  end
  𝒯 = (; zip(names, pcols)...)
  ptable = 𝒯 |> Tables.materializer(newtable)

  ptable, (ftrans, fcache, types)
end

function revert(::DropMissing, newtable, cache)
  ftrans, fcache, types = cache

  # pre-processing
  cols = Tables.columns(newtable)
  names = Tables.columnnames(newtable)
  pcols = map(zip(types, names)) do (T, n)
    x = Tables.getcolumn(cols, n)
    collect(T, x)
  end
  𝒯 = (; zip(names, pcols)...)
  ptable = 𝒯 |> Tables.materializer(newtable)

  revert(ftrans, ptable, fcache)
end

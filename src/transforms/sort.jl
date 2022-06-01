# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Sort(col; alg=DEFAULT_UNSTABLE, lt=isless, by=identity, rev=false, order=Forward)

Returns a table copy with rows sorted by values of a specific column.
The `col` value is a name (Symbol) that specifies the column used to sort.
The keyword arguments are the same as in the `sort` function.

# Examples

```julia
Sort(:a)
Sort(:a, rev=true)
```
"""

struct Sort{T} <: Stateless
  col::Symbol
  kwargs::T
end

Sort(col; kwargs...) = Sort(col, values(kwargs))

isrevertible(::Type{<:Sort}) = true

function apply(transform::Sort, table)
  # use selected column to calculate new order
  cols = Tables.columns(table)
  scol = Tables.getcolumn(cols, transform.col)
  inds = sortperm(scol; transform.kwargs...)

  # sort rows
  rows = Tables.rowtable(table)
  rows = rows[inds]

  newtable = rows |> Tables.materializer(table)
  newtable, inds
end

function revert(::Sort, newtable, cache)
  # use cache to recalculate old order
  inds = sortperm(cache)

  # undo rows sort
  rows = Tables.rowtable(newtable)
  rows = rows[inds]

  rows |> Tables.materializer(newtable)
end

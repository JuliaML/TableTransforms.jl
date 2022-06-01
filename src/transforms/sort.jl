# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Sort(col; rev=false)

Returns a table copy with rows sorted by values of a specific column.
The `col` value is a name (Symbol) that specifies the column used to sort.
Use `rev=true` to reverse the sorting order, the default value is `false`.

# Examples

```julia
Sort(:a)
Sort(:a, rev=true)
```
"""

struct Sort <: Stateless
  col::Symbol
  rev::Bool
end

Sort(col; rev=false) = Sort(col, rev)

isrevertible(::Type{<:Sort}) = true

function apply(transform::Sort, table)
  # use selected column to calculate new order
  cols = Tables.columns(table)
  scol = Tables.getcolumn(cols, transform.col)
  inds = sortperm(scol, rev=transform.rev)

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

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Sort(by, ascending)

Returns a table copy with rows sorted by values of a specific column.
The `by` value specifies the column used to sort, it can be a index (Int) or a name (Symbol).
The `ascending` value is a boolean that specifies the sort order, the default value is true.


# Examples

```julia
Sort(:a)
Sort(:a, ascending=true)
Sort(1)
Sort(1, ascending=false)
```
"""

struct Sort <: Stateless
  by::Union{Int, Symbol}
  ascending::Bool
end

Sort(by; ascending=true) = Sort(by, ascending)

isrevertible(::Type{<:Sort}) = true

function apply(transform::Sort, table)
  # use selected column to calculate new order
  scol = Tables.getcolumn(table, transform.by)
  neworder = sortperm(scol, rev=!transform.ascending)

  # sort rows
  rows = Tables.rowtable(table)
  rows = rows[neworder]

  newtable = rows |> Tables.materializer(table)
  newtable, neworder
end

function revert(::Sort, newtable, cache)
  # use cache to recalculate old order
  oldorder = sortperm(cache)

  # undo rows sort
  rows = Tables.rowtable(newtable)
  rows = rows[oldorder]

  rows |> Tables.materializer(newtable)
end

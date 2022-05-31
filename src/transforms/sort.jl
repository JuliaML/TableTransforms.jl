# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Sort(by, rev)

Returns a table copy with rows sorted by values of a specific column.
The `by` value specifies the column used to sort, it can be a index (Int) or a name (Symbol).
Use `rev=true` to reverse the sorting order, the default value is `false`.


# Examples

```julia
Sort(:a)
Sort(:a, rev=true)
Sort(1)
Sort(1, rev=false)
```
"""

struct Sort <: Stateless
  by::Union{Int, Symbol}
  rev::Bool
end

Sort(by; rev=false) = Sort(by, rev)

isrevertible(::Type{<:Sort}) = true

function apply(transform::Sort, table)
  # use selected column to calculate new order
  cols = Tables.columns(table)
  scol = Tables.getcolumn(cols, transform.by)
  neworder = sortperm(scol, rev=transform.rev)

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

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Filter(f)

The transform that filters the rows based on a given function.
"""
struct Filter{F} <: Transform
  pred::F
end

isrevertible(::Type{Filter}) = true

function apply(transform::Filter, table)
  # Converting to Tables.rowtable to allow length function and indexing 
  rows = Tables.rows(table)

  l = length(rows)
  f = transform.pred

  # Get indices of the desired rows
  indices = [i for i in range(1,length=l) if f(rows[i])]

  # Return:
  # - the desired rows as the new table,
  # - indices of these rows and the remaining rows as cache
  newtable = rows[indices]
  newtable |> Tables.materializer(table)
  remrows = rows[setdiff(1:length(rows), indices)]
  newtable, (indices, remrows)
end

function revert(::Type{Filter}, newtable, cache)
  for i in range(1, length=length(cache[1]))
    insert!(cache[2], cache[1][i], newtable[i])
  end

  cache[2]
end

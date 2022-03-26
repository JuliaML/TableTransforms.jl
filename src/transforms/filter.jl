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

function apply(transform::Filter, input_table)
  # Converting to Tables.rowtable to allow length function and indexing 
  table = Tables.rows(input_table)

  l = length(table)
  f = transform.pred

  # Get indices of the desired rows
  indices = [i for i in range(1,length=l) if f(table[i])]

  # Return:
  # - the desired rows as the new table,
  # - indices of these rows and the remaining rows as cache
  new_table = table[indices]
  new_table |> Tables.materializer(input_table)
  rem_rows = table[setdiff(1:length(table), indices)]
  new_table, (indices, rem_rows)
end

function revert(::Type{Filter}, newtable, cache)
  indices = copy(cache[1])
  orgtable = copy(cache[2])

  for i in range(1, length=length(indices))
    insert!(orgtable, indices[i], newtable[i])
  end

  orgtable
end

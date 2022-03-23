# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Filter(f, table)

The transform that filters the rows based on a given function.
"""
struct Filter{F} <: Transform
  pred::F
end

# Default filter to be used when no input function is given
# Returns true if any element in the row evaluates to true
Filter() = Filter(row -> any(row))

isrevertible(::Type{Filter}) = true

function apply(transform::Filter, input_table)
  # Converting to Tables.rowtable to allow length function and indexing 
  table = Tables.rowtable(input_table)

  # Get indices of the desired rows
  indices = [i for i in range(1,length=length(table)) if transform.pred(table[i])]

  # Return:
  # - the desired rows as the new table,
  # - indices of these rows and the remaining rows as cache
  table[indices], (indices, table[setdiff(1:length(table), indices)])
end

function revert(::Type{Filter}, newtable, cache)
  indices = copy(cache[1])
  orgtable = copy(cache[2])

  for i in range(1, length=length(indices))
    insert!(orgtable, indices[i], newtable[i])
  end

  orgtable
end

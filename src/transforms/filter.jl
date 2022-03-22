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

Filter() = Filter(_default_filter)

isrevertible(::Type{Filter}) = true

function apply(transform::Filter, input_table)
  table = Tables.rowtable(input_table)
  indices = [i for i in range(1,length=length(table)) if transform.pred(table[i])]
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

# Exclude the given indices
_minus(indx, x) = setdiff(1:length(x), indices)

# Default filter to be used when no input function is given
# Returns true if any element in the row evaluates to true
function _default_filter(row)
  return any(row)
end
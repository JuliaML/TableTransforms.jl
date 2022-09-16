# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    ColTable()

The transform that applies the function `Tables.columntable` to to the input table.
"""
struct ColTable <: Stateless end

isrevertible(::Type{ColTable}) = true

apply(::ColTable, table) = Tables.columntable(table), table

revert(::ColTable, newtable, cache) = cache

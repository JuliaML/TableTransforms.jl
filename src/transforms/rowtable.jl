# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    RowTable()

The transform that applies the function `Tables.rowtable` to to the input table.
"""
struct RowTable <: Stateless end

isrevertible(::Type{RowTable}) = true

applyfeat(::RowTable, table, prep) = Tables.rowtable(table), table

revertfeat(::RowTable, newtable, cache) = cache

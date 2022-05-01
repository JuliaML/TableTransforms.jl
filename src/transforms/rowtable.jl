# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    RowTable()

The transform that applies the function `Tables.rowtable` to to the input table.
"""
struct RowTable <: Transform end

apply(::RowTable, table) = Tables.rowtable(table), table

revert(::RowTable, table, cache) = cache

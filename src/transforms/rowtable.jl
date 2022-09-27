# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    RowTable()

The transform that applies the function `Tables.rowtable` to to the input table.
"""
struct RowTable <: StatelessTableTransform end

isrevertible(::Type{RowTable}) = true

applyfeat(::RowTable, feat, prep) = Tables.rowtable(feat), feat

revertfeat(::RowTable, newfeat, fcache) = fcache

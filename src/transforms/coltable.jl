# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    ColTable()

The transform that applies the function `Tables.columntable` to to the input table.
"""
struct ColTable <: StatelessFeatureTransform end

isrevertible(::Type{ColTable}) = true

applyfeat(::ColTable, feat, prep) = Tables.columntable(feat), feat

revertfeat(::ColTable, newfeat, fcache) = fcache

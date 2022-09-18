# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Identity()

The identity transform `x -> x`.
"""
struct Identity <: Stateless end

isrevertible(::Type{Identity}) = true

applyfeat(::Identity, table) = table, nothing

revertfeat(::Identity, newtable, cache) = newtable
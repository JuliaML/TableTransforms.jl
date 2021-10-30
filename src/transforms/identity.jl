# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Identity()

The identity transform `x -> x`.
"""
struct Identity <: Stateless end

isrevertible(::Type{Identity}) = true

apply(::Identity, table) = table, nothing

revert(::Identity, newtable, cache) = newtable
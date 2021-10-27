# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Identity()

The identity transform `x -> x`.
"""
struct Identity <: Transform end

isinvertible(::Type{Identity}) = true

forward(::Identity, table) = table, nothing

backward(::Identity, newtable, cache) = newtable
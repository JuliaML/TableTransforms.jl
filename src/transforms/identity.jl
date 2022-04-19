# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Identity()

The identity transform `x -> x`.

# Examples

T = Identity()

## Notes

* The schema of the table is preserved by the transform.
"""
struct Identity <: Stateless end

isrevertible(::Type{Identity}) = true

apply(::Identity, table) = table, nothing

revert(::Identity, newtable, cache) = newtable
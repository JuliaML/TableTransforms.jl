# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    NarrowTypes()

Converts the element type of columns with generic types to more specific types.
"""
struct NarrowTypes <: Colwise end

isrevertible(::Type{NarrowTypes}) = true

colcache(::NarrowTypes, x) = eltype(x)

colapply(::NarrowTypes, x, c) = identity.(x)

colrevert(::NarrowTypes, y, c) = collect(c, y)

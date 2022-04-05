# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Coerce(S::DataType)

Return a new versions of the table whose scientific element types are S.
"""
struct Coerce{S} <: Colwise
  type::S
end

assertions(::Type{Coerce}) = [assert_continuous]

isrevertible(::Type{<:Coerce}) = true

colcache(::Coerce, x) = ScientificTypes.elscitype(x)

colapply(transform::Coerce, x, c) = ScientificTypes.coerce(x, transform.type)

colrevert(transform::Coerce, y, c) = ScientificTypes.coerce(y, c)

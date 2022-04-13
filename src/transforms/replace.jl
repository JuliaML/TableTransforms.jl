# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Replace(old₁ => new₁, old₂ => new₂, ..., oldₙ => newₙ)

Replaces `oldᵢ` value with `newᵢ` value in the table.
"""
struct Replace{K,V} <: Colwise
  pairs::IdDict{K,V}
end

Replace() = throw(ArgumentError("Cannot create a Replace object without arguments."))

Replace(pairs::Pair...) = Replace(IdDict(values(pairs)))

isrevertible(::Type{<:Replace}) = true

function colcache(transform::Replace, x)
  olds = keys(transform.pairs)
  inds = [findall(v -> v === old, x) .=> old for old in olds]
  Dict(reduce(vcat, inds))
end

colapply(transform::Replace, x, c) =
  map(v -> get(transform.pairs, v, v), x)

colrevert(::Replace, x, c) =
  map(i -> get(c, i, x[i]), 1:length(x))

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------
"""
    Replace(old₁ => new₁, old₂ => new₂, ..., oldₙ => newₙ)

Replaces all occurrences of `oldᵢ` with `newᵢ` in the table.
"""
struct Replace{K,V} <: Colwise
  oldnew::IdDict{K,V}
end

Replace() = throw(ArgumentError("Cannot create a Replace object without arguments."))

Replace(oldnew::Pair...) = Replace(IdDict(values(oldnew)))

isrevertible(::Type{<:Replace}) = true

function colcache(transform::Replace, x)
  olds = keys(transform.oldnew)
  inds = [findall(v -> v === old, x) .=> old for old in olds]
  Dict(reduce(vcat, inds))
end

colapply(transform::Replace, x, c) =
  map(v -> get(transform.oldnew, v, v), x)

colrevert(::Replace, x, c) =
  map(i -> get(c, i, x[i]), 1:length(x))

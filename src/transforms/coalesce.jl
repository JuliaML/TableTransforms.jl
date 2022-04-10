# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

struct Coalesce{T} <: Colwise
  default::T
end

isrevertible(::Type{<:Coalesce}) = true

colcache(::Coalesce, x) = findall(ismissing, x)

colapply(tramsform::Coalesce, x, c) =
  coalesce.(x, tramsform.default)

colrevert(::Coalesce, x, c) =
  map(i -> i ∈ c ? missing : x[i], 1:length(x))

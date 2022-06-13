# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Coalesce(value)

Replaces all missing values from the table with `value`.

# Examples

```julia
Coalesce(0)
```

## Notes

* The transform can alter the element type of columns from `Union{Missing,T}` to `T`.
"""
struct Coalesce{T} <: Colwise
  value::T
end

isrevertible(::Type{<:Coalesce}) = true

colcache(::Coalesce, x) = findall(ismissing, x)

colapply(tramsform::Coalesce, x, c) = coalesce.(x, tramsform.value)

colrevert(::Coalesce, y, c) = [i ∈ c ? missing : y[i] for i in 1:length(y)]

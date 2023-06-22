# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Coalesce(; value)

Replaces all missing values from the table with `value`.

    Coalesce(col₁, col₂, ..., colₙ; value)
    Coalesce([col₁, col₂, ..., colₙ]; value)
    Coalesce((col₁, col₂, ..., colₙ); value)

Replaces all missing values from the columns
`col₁`, `col₂`, ..., `colₙ` with `value`.

    Coalesce(regex; value)

Replaces all missing values from the columns
that match with `regex` with `value`.

# Examples

```julia
Coalesce(value=0)
Coalesce(1, 3, 5, value=1)
Coalesce([:a, :c, :e], value=2)
Coalesce(("a", "c", "e"), value=3)
Coalesce(r"[ace]", value=4)
```

## Notes

* The transform can alter the element type of columns from `Union{Missing,T}` to `T`.
"""
struct Coalesce{S<:ColSpec,T} <: ColwiseFeatureTransform
  colspec::S
  value::T
end

Coalesce(; value) = Coalesce(AllSpec(), value)
Coalesce(spec; value) = Coalesce(colspec(spec), value)
Coalesce(cols::C...; value) where {C<:Col} = Coalesce(colspec(cols), value)

isrevertible(::Type{<:Coalesce}) = true

colcache(::Coalesce, x) = findall(ismissing, x)

colapply(transform::Coalesce, x, c) = coalesce.(x, transform.value)

colrevert(::Coalesce, y, c) = [i ∈ c ? missing : y[i] for i in 1:length(y)]

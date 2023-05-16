# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Center()

Applies the center transform to all columns of the table.
The center transform of the column `x`, with mean `μ`,
is defined by `x .- μ`.

    Center(col₁, col₂, ..., colₙ)
    Center([col₁, col₂, ..., colₙ])
    Center((col₁, col₂, ..., colₙ))

Applies the Center transform on columns `col₁`, `col₂`, ..., `colₙ`.

    Center(regex)

Applies the Center transform on columns that match with `regex`.

# Examples
```julia
Center(1, 3, 5)
Center([:a, :c, :e])
Center(("a", "c", "e"))
Center(r"[ace]")
```
"""
struct Center{S<:ColSpec} <: ColwiseFeatureTransform
  colspec::S
end

Center() = Center(AllSpec())
Center(spec) = Center(colspec(spec))
Center(cols::C...) where {C<:Col} = Center(colspec(cols))

assertions(transform::Center) = [SciTypeAssertion{Continuous}(transform.colspec)]

isrevertible(::Type{<:Center}) = true

colcache(::Center, x) = mean(x)

colapply(::Center, x, μ) = @. x - μ

colrevert(::Center, y, μ) = @. y + μ

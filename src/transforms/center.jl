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
struct Center{S<:ColumnSelector} <: ColwiseFeatureTransform
  selector::S
end

Center() = Center(AllSelector())
Center(cols) = Center(selector(cols))
Center(cols::C...) where {C<:Column} = Center(selector(cols))

assertions(transform::Center) = [SciTypeAssertion(transform.selector, scitype=Continuous)]

isrevertible(::Type{<:Center}) = true

colcache(::Center, x) = mean(x)

colapply(::Center, x, μ) = @. x - μ

colrevert(::Center, y, μ) = @. y + μ

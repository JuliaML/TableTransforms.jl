# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    ZScore()

Applies the z-score transform (a.k.a. normal score) to all columns of the table.
The z-score transform of the column `x`, with mean `μ` and standard deviation `σ`,
is defined by `(x .- μ) ./ σ`.

    ZScore(col₁, col₂, ..., colₙ)
    ZScore([col₁, col₂, ..., colₙ])
    ZScore((col₁, col₂, ..., colₙ))

Applies the ZScore transform on columns `col₁`, `col₂`, ..., `colₙ`.

    ZScore(regex)

Applies the ZScore transform on columns that match with `regex`.

## Examples

```julia
ZScore(1, 3, 5)
ZScore([:a, :c, :e])
ZScore(("a", "c", "e"))
ZScore(r"[ace]")
```
"""
struct ZScore{S<:ColumnSelector} <: ColwiseFeatureTransform
  selector::S
end

ZScore() = ZScore(AllSelector())
ZScore(cols) = ZScore(selector(cols))
ZScore(cols::C...) where {C<:Column} = ZScore(selector(cols))

assertions(transform::ZScore) = [scitypeassert(Continuous, transform.selector)]

isrevertible(::Type{<:ZScore}) = true

function colcache(::ZScore, x)
  μ = mean(skipmissing(x))
  σ = std(skipmissing(x), mean=μ)
  (μ=μ, σ=σ)
end

colapply(::ZScore, x, c) = zscore(x, c.μ, c.σ)

colrevert(::ZScore, y, c) = revzscore(y, c.μ, c.σ)

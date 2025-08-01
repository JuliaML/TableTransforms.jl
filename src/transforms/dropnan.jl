# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DropNaN()
    DropNaN(:)

Drop all rows with NaN values in table.

    DropNaN(col₁, col₂, ..., colₙ)
    DropNaN([col₁, col₂, ..., colₙ])
    DropNaN((col₁, col₂, ..., colₙ))

Drop all rows with NaN values in selected columns `col₁`, `col₂`, ..., `colₙ`.

    DropNaN(regex)

Drop all rows with NaN values in columns that match with `regex`.

## Examples

```julia
DropNaN(2, 3, 4)
DropNaN([:b, :c, :d])
DropNaN(("b", "c", "d"))
DropNaN(r"[bcd]")
```
"""
struct DropNaN{S<:ColumnSelector} <: StatelessFeatureTransform
  selector::S
end

DropNaN() = DropNaN(AllSelector())
DropNaN(cols) = DropNaN(selector(cols))
DropNaN(cols::C...) where {C<:Column} = DropNaN(selector(cols))

_isnan(_) = false
_isnan(x::Number) = isnan(x)

function preprocess(transform::DropNaN, feat)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = transform.selector(names)
  ftrans = Filter(row -> all(!_isnan(row[nm]) for nm in snames))
  fprep = preprocess(ftrans, feat)
  ftrans, fprep
end

function applyfeat(::DropNaN, feat, prep)
  ftrans, fprep = prep
  applyfeat(ftrans, feat, fprep)
end

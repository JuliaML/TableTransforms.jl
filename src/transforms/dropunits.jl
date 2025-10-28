# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DropUnits()
    DropUnits(:)

Drop units from all columns in the table.

    DropUnits(col₁, col₂, ..., colₙ)
    DropUnits([col₁, col₂, ..., colₙ])
    DropUnits((col₁, col₂, ..., colₙ))

Drop units from selected columns `col₁`, `col₂`, ..., `colₙ`.

    DropUnits(regex)

Drop units from columns that match with `regex`.

## Examples

```julia
DropUnits()
DropUnits([2, 3, 5])
DropUnits([:b, :c, :e])
DropUnits(("b", "c", "e"))
DropUnits(r"[bce]")
```
"""
struct DropUnits{S<:ColumnSelector} <: StatelessFeatureTransform
  selector::S
end

DropUnits() = DropUnits(AllSelector())
DropUnits(cols) = DropUnits(selector(cols))
DropUnits(cols::C...) where {C<:Column} = DropUnits(selector(cols))

isrevertible(::Type{<:DropUnits}) = true

function applyfeat(transform::DropUnits, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = transform.selector(names)

  tuples = map(names) do name
    x = Tables.getcolumn(cols, name)
    name ∈ snames ? _dropunit(x) : (x, NoUnits)
  end

  columns = first.(tuples)
  units = last.(tuples)

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)
  newfeat, (snames, units)
end

function revertfeat(::DropUnits, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)

  snames, units = fcache
  columns = map(names, units) do name, unit
    x = Tables.getcolumn(cols, name)
    name ∈ snames ? _withunit(x, unit) : x
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

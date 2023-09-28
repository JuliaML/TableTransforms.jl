# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbsoluteUnits()
    AbsoluteUnits(:)

Converts the units of all columns in the table to absolute units.

    AbsoluteUnits(col₁, col₂, ..., colₙ)
    AbsoluteUnits([col₁, col₂, ..., colₙ])
    AbsoluteUnits((col₁, col₂, ..., colₙ))

Converts the units of selected columns `col₁`, `col₂`, ..., `colₙ` to absolute units.

    AbsoluteUnits(regex)

Converts the units of columns that match with `regex` to absolute units.

# Examples

```julia
AbsoluteUnits()
AbsoluteUnits([2, 3, 5])
AbsoluteUnits([:b, :c, :e])
AbsoluteUnits(("b", "c", "e"))
AbsoluteUnits(r"[bce]")
```
"""
struct AbsoluteUnits{S<:ColSpec} <: StatelessFeatureTransform
  colspec::S
end

AbsoluteUnits() = AbsoluteUnits(AllSpec())
AbsoluteUnits(spec) = AbsoluteUnits(colspec(spec))
AbsoluteUnits(cols::T...) where {T<:Col} = AbsoluteUnits(colspec(cols))

isrevertible(::Type{<:AbsoluteUnits}) = true

_absunit(x) = _absunit(x, nonmissingtype(eltype(x)))
_absunit(x, ::Type) = (x, NoUnits)
_absunit(x, ::Type{Q}) where {Q<:AbstractQuantity} = (x, unit(Q)) 
function _absunit(x, ::Type{Q}) where {Q<:AffineQuantity}
  u = absoluteunit(unit(Q))
  y = map(v -> uconvert(u, v), x)
  (y, u)
end

function applyfeat(transform::AbsoluteUnits, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = choose(transform.colspec, names)

  tuples = map(names) do name
    x = Tables.getcolumn(cols, name)
    name ∈ snames ? _absunit(x) : (x, NoUnits)
  end

  columns = first.(tuples)
  units = last.(tuples)

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)
  newfeat, (snames, units)
end

_revunit(x, ::Units) = x
_revunit(x, u::AbsoluteUnits) = map(v -> uconvert(u, v), x)

function revertfeat(::AbsoluteUnits, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)

  snames, units = fcache
  columns = map(names, units) do name, unit
    x = Tables.getcolumn(cols, name)
    name ∈ snames ? _revunit(x, unit) : x
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

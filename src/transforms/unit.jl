# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Unit(unit)

Converts the units of all columns in the table to `unit` from Unitful.jl.

    Unit(cols₁ => unit₁, cols₂ => unit₂, ..., colsₙ => unitₙ)

Converts the units of selected columns `cols₁`, `cols₂`, ..., `colsₙ`
to `unit₁`, `unit₂`, ... `unitₙ`.

Unitless columns become unitful if they are explicitly selected.

## Examples

```julia
Unit(u"m")
Unit(1 => u"km", :b => u"K", "c" => u"s")
Unit([2, 3] => u"cm")
Unit([:a, :c] => u"cm")
Unit(["a", "c"] => u"cm")
Unit(r"[abc]" => u"km")
```
"""
struct Unit <: StatelessFeatureTransform
  selectors::Vector{ColumnSelector}
  units::Vector{Units}
end

Unit() = throw(ArgumentError("cannot create Unit transform without arguments"))

Unit(unit::Units) = Unit([AllSelector()], [unit])

Unit(pairs::Pair...) = Unit(collect(selector.(first.(pairs))), collect(last.(pairs)))

isrevertible(::Type{<:Unit}) = true

function applyfeat(transform::Unit, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)

  selectors = transform.selectors
  units = transform.units
  pairs = mapreduce(vcat, selectors, units) do selector, u
    snames = selector(names)
    snames .=> u
  end
  unitdict = Dict(pairs)

  tuples = map(names) do name
    x = Tables.getcolumn(cols, name)
    if haskey(unitdict, name)
      u = unitdict[name]
      _withunit(u, x)
    else
      (x, nothing)
    end
  end

  columns = first.(tuples)
  ounits = last.(tuples)

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)
  newfeat, ounits
end

function revertfeat(::Unit, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)

  ounits = fcache
  columns = map(names, ounits) do name, u
    x = Tables.getcolumn(cols, name)
    _withoutunit(u, x)
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

_withunit(u, x) = _withunit(nonmissingtype(eltype(x)), u, x)
_withunit(::Type{Q}, u, x) where {Q<:AbstractQuantity} = (map(v -> uconvert(u, v), x), unit(Q))
_withunit(::Type{Q}, u, x) where {Q<:Number} = (x * u, NoUnits)

function _withoutunit(u, x)
  if u === NoUnits
    map(ustrip, x)
  else
    map(xᵢ -> uconvert(u, xᵢ), x)
  end
end
_withoutunit(::Nothing, x) = x

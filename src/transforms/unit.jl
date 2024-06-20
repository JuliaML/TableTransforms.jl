# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Unit(unit)

Converts the units of all columns in the table to `unit`.

    Unit(cols₁ => unit₁, cols₂ => unit₂, ..., colsₙ => unitₙ)

Converts the units of selected columns `cols₁`, `cols₂`, ..., `colsₙ`
to `unit₁`, `unit₂`, ... `unitₙ`.

The column selection can be a single column identifier (index or name),
a collection of identifiers or a regular expression (regex).

# Examples

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

_uconvert(u, x) = _uconvert(nonmissingtype(eltype(x)), u, x)
_uconvert(::Type, _, x) = (x, nothing)
_uconvert(::Type{Q}, u, x) where {Q<:AbstractQuantity} = (map(v -> uconvert(u, v), x), unit(Q))

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
      _uconvert(u, x)
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
    isnothing(u) ? x : map(v -> uconvert(u, v), x)
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

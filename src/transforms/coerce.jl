# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Coerce(col₁ => S₁, col₂ => S₂, ..., colₙ => Sₙ)

Return a copy of the table, ensuring that the scientific types of the columns match the new specification.

    Coerce(S)

Coerce all columns of the table with scientific type `S`.

This transform uses the `DataScienceTraits.coerce` function. Please see their docstring for more details.

# Examples

```julia
using DataScienceTraits
Coerce(1 => Continuous, 2 => Continuous)
Coerce(:a => Continuous, :b => Continuous)
Coerce("a" => Continuous, "b" => Continuous)
```
"""
struct Coerce{S<:ColumnSelector,T} <: StatelessFeatureTransform
  selector::S
  scitypes::T
end

Coerce() = throw(ArgumentError("cannot create Coerce transform without arguments"))

Coerce(scitype::Type{<:SciType}) = Coerce(AllSelector(), scitype)

Coerce(pairs::Pair{C,DataType}...) where {C<:Column} = Coerce(selector(first.(pairs)), collect(last.(pairs)))

isrevertible(::Type{<:Coerce}) = true

_typedict(scitype::Type{<:SciType}, snames) = Dict(nm => scitype for nm in snames)
_typedict(scitypes::AbstractVector, snames) = Dict(zip(snames, scitypes))

function applyfeat(transform::Coerce, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  types = Tables.schema(feat).types
  snames = transform.selector(names)
  typedict = _typedict(transform.scitypes, snames)

  columns = map(names) do name
    x = Tables.getcolumn(cols, name)
    name ∈ snames ? coerce(typedict[name], x) : x
  end

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)

  newfeat, types
end

function revertfeat(::Coerce, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)

  columns = map(fcache, names) do T, n
    x = Tables.getcolumn(cols, n)
    collect(T, x)
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

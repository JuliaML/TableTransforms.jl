# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Coerce(pairs, tight=false, verbosity=1)

Return a copy of the table, ensuring that the scientific types of the columns match the new specification.

This transform wraps the ScientificTypes.coerce function. Please see their docstring for more details.

# Examples

```julia
using ScientificTypes
Coerce(:col1 => Continuous, :col2 => Count)
```
"""
struct Coerce{P} <: FeatureTransform
  pairs::P
  tight::Bool
  verbosity::Int
end

Coerce(pairs::Pair{Symbol,<:Type}...; tight=false, verbosity=1) = Coerce(pairs, tight, verbosity)
Coerce(pairs::Pair{<:AbstractString,<:Type}...; kwargs...) = Coerce((Symbol(k) => v for (k, v) in pairs)...; kwargs...)

isrevertible(::Type{<:Coerce}) = true

function applyfeat(transform::Coerce, feat, prep)
  newtable = coerce(feat, transform.pairs...; tight=transform.tight, verbosity=transform.verbosity)

  types = Tables.schema(feat).types

  newtable, types
end

function revertfeat(::Coerce, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)

  oldcols = map(zip(fcache, names)) do (T, n)
    x = Tables.getcolumn(cols, n)
    collect(T, x)
  end

  𝒯 = (; zip(names, oldcols)...)
  𝒯 |> Tables.materializer(newfeat)
end

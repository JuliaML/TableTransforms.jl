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
struct Coerce{P} <: Transform
  pairs::P
  tight::Bool
  verbosity::Int
end

Coerce(pair::Pair{Symbol,<:Type}...; tight=false, verbosity=1) = 
  Coerce(pair, tight, verbosity)

isrevertible(::Type{<:Coerce}) = true

function applyfeat(transform::Coerce, table, prep)
  newtable = coerce(table, transform.pairs...;
                    tight=transform.tight,
                    verbosity=transform.verbosity)

  types = Tables.schema(table).types
  
  newtable, types
end

function revertfeat(::Coerce, newtable, cache)
  cols = Tables.columns(newtable)
  names = Tables.columnnames(cols)
  
  oldcols = map(zip(cache, names)) do (T, n)
    x = Tables.getcolumn(cols, n)
    collect(T, x)
  end
    
  𝒯 = (; zip(names, oldcols)...)
  𝒯 |> Tables.materializer(newtable)
end

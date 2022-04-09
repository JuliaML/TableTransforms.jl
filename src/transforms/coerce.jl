# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Coerce(pairs, tight=false, verbosity=1)

Return a copy of the table, ensuring that the scientific types of the columns match the new specification.

This transform wraps the ScientificTypes.coerce function. Please see their docstring for more details.

```julia
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

function apply(transform::Coerce, table)
  newtable = coerce(table, transform.pairs...;
                    tight=transform.tight,
                    verbosity=transform.verbosity)

  types = Tables.schema(table).types
  
  newtable, types
end

function revert(transform::Coerce, newtable, cache)
  names = Tables.columnnames(newtable)
  cols = Tables.columns(newtable)
  newcols = [collect(T, Tables.getcolumn(cols, n)) for (T, n) in zip(cache, names)]
  
  𝒯 = (; zip(colnames, newcols)...)
  𝒯 |> Tables.materializer(newtable)
end

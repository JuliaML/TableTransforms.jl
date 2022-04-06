# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Coerce(pairs, tight=false, verbosity=1)

Return a copy of the table, ensuring that the element scitypes of the columns match the new specification.

Valid specifications (more to be added):

(1) one or more column_name=>Scitype pairs
"""
struct Coerce{P, T, V} <: Transform
  pairs::P
  tight::T
  verbosity::V
end

Coerce(pair...; tight=false, verbosity=1) = Coerce(pair, tight, verbosity)

isrevertible(::Type{<:Coerce}) = true

function apply(transform::Coerce, table)
  newtable = ScientificTypes.coerce(table, transform.pairs...; tight=transform.tight, verbosity=transform.verbosity)

  scitypes = [ScientificTypes.elscitype(x) for x in Tables.columns(table)]
  colnames = Tables.columnnames(table)
  pairs = [Pair(i, j) for (i, j) in zip(colnames, scitypes)]
  
  return newtable, pairs
end

revert(transform::Coerce, newtable, cache) = ScientificTypes.coerce(newtable, cache...)

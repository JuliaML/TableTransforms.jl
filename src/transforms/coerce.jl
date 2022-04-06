# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Coerce(P)

Return a new versions of the table whose scientific element types are S.
"""
struct Coerce{P} <: Transform
  pairs::P
end

Coerce(pair...) = Coerce(pair)

isrevertible(::Type{<:Coerce}) = true

function apply(transform::Coerce, table)
  newtable = ScientificTypes.coerce(table, transform.pairs...)

  scitypes = [ScientificTypes.elscitype(x) for x in Tables.columns(table)]
  colnames = Tables.columnnames(table)
  pairs = [Pair(i, j) for (i, j) in zip(colnames, scitypes)]
  
  return newtable, pairs
end

revert(transform::Coerce, newtable, cache) = ScientificTypes.coerce(newtable, cache...)

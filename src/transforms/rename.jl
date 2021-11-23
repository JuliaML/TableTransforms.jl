# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
  Rename(:col₁ => :newcol₁, :col₂ => :newcol₂, ..., :col₁ => :newcolₙ)

The transform that renames `col₁` to `newcol₁`, `col₂` to `newcol₂`, ...
"""
struct Rename <: Stateless
  names::Dict{Symbol,Symbol}
end

pairsyms(x::Pair) = Symbol(first(x)) => Symbol(last(x))

Rename(names::Pair) = pairsyms(names) |> Dict |> Rename
Rename(names...) = pairsyms.(names) |> Dict |> Rename

function apply(transform::Rename, table)
  _rename(transform.names, table)
end

function revert(transform::Rename, table, cache)
  # reversing the key-value pairs of the Dict
  newnames = Dict()
  for (old, new) in transform.names
    newnames[new] = old
  end
  _rename(newnames, table) |> first
end


function _rename(names, table)
  oldnames = Tables.columnnames(table)

  # check if requested renames exist in the table
  diff = setdiff(keys(names), oldnames) .|> String |> Tuple
  @assert length(diff) == 0
    "The following column[s] were not found in the source table: $diff"

  newnames = map(oldnames) do oldname
    oldname in keys(names) ? names[oldname] : oldname
  end

  cols = Tables.columns(table)
  vals = [Tables.getcolumn(cols, name) for name in oldnames]
  𝒯 = (; zip(newnames, vals)...) |> Tables.materializer(table)
  
  𝒯, nothing
end
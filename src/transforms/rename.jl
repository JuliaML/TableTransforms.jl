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

function apply(transform::Rename, table)
  oldnames = Tables.columnnames(table)
  newnames = map(oldnames) do oldname
    if oldname in keys(transform.names)
      return transform.names[oldname]
    else
      return oldname
    end
  end
  acols = [i for i in Tables.columns(table)]
  𝒯 = (; zip(newnames, acols)...) |> Tables.materializer(table)
  𝒯, nothing
end

function revert(transform::Rename, table)
  # reversing the key-value pairs of the Dict
  new_names = Dict()
  for (new, old) in transform.names
    new_names[old] = new
  end

  reversed_transform = Rename(new_names)
  apply(reversed_transform, table) |> first
end

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    TableSelection(table, names)

Stores a sub-`table` with given column `names`.
"""
struct TableSelection{T,N}
  table::T
  names::NTuple{N,Symbol}
  oinds::NTuple{N,Int}
end

function TableSelection(table, names)
  cols = Tables.columns(table)
  onames = Tables.columnnames(cols)
  _assert(names ⊆ onames, "invalid columns for table selection")
  oinds = indexin(collect(names), collect(onames))
  TableSelection(table, Tuple(names), Tuple(oinds))
end

Tables.istable(::Type{<:TableSelection}) = true

Tables.columnaccess(::Type{<:TableSelection}) = true

Tables.columns(t::TableSelection) = t

Tables.columnnames(t::TableSelection) = t.names

Tables.getcolumn(t::TableSelection, i::Int) = Tables.getcolumn(Tables.columns(t.table), t.oinds[i])

Tables.getcolumn(t::TableSelection, nm::Symbol) = Tables.getcolumn(Tables.columns(t.table), nm)

Tables.materializer(t::TableSelection) = Tables.materializer(t.table)
function Tables.schema(t::TableSelection)
  schema = Tables.schema(t.table)
  names = [schema.names[i] for i in t.oinds]
  types = [schema.types[i] for i in t.oinds]
  Tables.Schema(names, types)
end

function Base.show(io::IO, t::TableSelection)
  println(io, "TableSelection")
  pretty_table(io, t, vcrop_mode=:bottom, newline_at_end=false)
end

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

struct TableSelection{T,C}
  table::T
  cols::C
  ncols::Int
  names::Vector{Symbol}
  onames::Vector{Symbol}
  mapnames::Dict{Symbol,Symbol}

  function TableSelection(table::T, names, onames) where {T}
    cols = Tables.columns(table)
    @assert onames ⊆ Tables.columnnames(cols)
    ncols = length(names)
    mapnames = Dict(zip(names, onames))
    new{T,typeof(cols)}(table, cols, ncols, names, onames, mapnames)
  end
end

function Base.:(==)(a::TableSelection, b::TableSelection)
  a.names  != b.names  && return false
  a.onames != b.onames && return false
  all(nm -> Tables.getcolumn(a, nm) == Tables.getcolumn(b, nm), a.names)
end

function Base.show(io::IO, t::TableSelection)
  println(io, "TableSelection")
  pretty_table(io, t,
    vcrop_mode=:middle,
    newline_at_end=false
  )
end

# Tables.jl interface
Tables.istable(::Type{<:TableSelection}) = true
Tables.columnaccess(::Type{<:TableSelection}) = true
Tables.columns(t::TableSelection) = t
Tables.columnnames(t::TableSelection) = t.names

function Tables.getcolumn(t::TableSelection, i::Int)
  1 ≤ i ≤ t.ncols || error("Table has no column with index $i.")
  Tables.getcolumn(t.cols, t.mapnames[t.names[i]])
end

function Tables.getcolumn(t::TableSelection, nm::Symbol)
  nm ∉ t.names && error("Table has no column $nm.")
  Tables.getcolumn(t.cols, t.mapnames[nm])
end

Tables.materializer(t::TableSelection) =
  Tables.materializer(t.table)

function Tables.schema(t::TableSelection)
  schema = Tables.schema(t.cols)
  names  = schema.names
  types  = schema.types
  inds   = indexin(t.onames, collect(names))
  Tables.Schema(t.names, types[inds])
end

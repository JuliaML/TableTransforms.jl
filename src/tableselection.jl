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
Tables.rowaccess(::Type{<:TableSelection}) = true
Tables.rows(t::TableSelection) = SelectionRows(t)
Tables.columnnames(t::TableSelection) = t.names

function Tables.getcolumn(t::TableSelection, i::Int)
  i > t.ncols && error("Table has no column with index $i.")
  Tables.getcolumn(t.cols, t.names[i])
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

# SelectionRow
struct SelectionRow{T<:TableSelection}
  selection::T
  ncols::Int
  ind::Int
end

SelectionRow(t::TableSelection, ind::Int) = SelectionRow(t, t.ncols, ind)

function Base.:(==)(a::SelectionRow, b::SelectionRow)
  a.ind   != b.ind   && return false
  a.ncols != b.ncols && return false
  a.selection == b.selection
end

function Base.show(io::IO, row::SelectionRow)
  println(io, "SelectionRow")
  names  = row.selection.names
  vecrow = [Tables.getcolumn(row, nm) for nm in names]
  matrow = transpose(vecrow)
  pretty_table(io, matrow,
    header=names,
    vcrop_mode=:middle,
    newline_at_end=false
  )
end

# Iteration interface
Base.iterate(row::SelectionRow, state::Int=1) =
  state > row.ncols ? nothing : (row[state], state + 1)

Base.length(row::SelectionRow) = row.ncols
Base.IteratorSize(::Type{<:SelectionRow}) = Base.HasLength()
Base.IteratorEltype(::Type{<:SelectionRow}) = Base.EltypeUnknown()

# Indexing interface
Base.firstindex(::SelectionRow) = 1
Base.lastindex(row::SelectionRow) = row.ncols
Base.getindex(row::SelectionRow, i::Int) = Tables.getcolumn(row, i)

# Tables.jl row interface
Tables.columnnames(row::SelectionRow) = row.selection.names
Tables.getcolumn(row::SelectionRow, i::Int) =
  Tables.getcolumn(row.selection, i)[row.ind]
Tables.getcolumn(row::SelectionRow, nm::Symbol) =
  Tables.getcolumn(row.selection, nm)[row.ind]

# SelectionRows
struct SelectionRows{T<:TableSelection}
  selection::T
  nrows::Int
end

SelectionRows(t::TableSelection) = SelectionRows(t, _nrows(t.cols))

function Base.:(==)(a::SelectionRows, b::SelectionRows)
  a.nrows != b.nrows && return false
  a.selection == b.selection
end

function Base.show(io::IO, s::SelectionRows)
  println(io, "SelectionRows")
  pretty_table(io, s.selection,
    vcrop_mode=:middle,
    newline_at_end=false
  )
end

# Iteration interface
Base.iterate(s::SelectionRows, state::Int=1) =
  state > s.nrows ? nothing : (s[state], state + 1)

Base.length(row::SelectionRows) = row.nrows
Base.eltype(::Type{SelectionRows{T}}) where {T} = SelectionRow{T}
Base.IteratorSize(::Type{<:SelectionRows}) = Base.HasLength()
Base.IteratorEltype(::Type{<:SelectionRows}) = Base.HasEltype()

# Indexing interface
Base.firstindex(::SelectionRows) = 1
Base.lastindex(s::SelectionRows) = s.nrows
Base.getindex(s::SelectionRows, i::Int) = SelectionRow(s.selection, i)

# Tables.jl interface
Tables.isrowtable(::Type{<:SelectionRows}) = true
Tables.columnaccess(::Type{<:SelectionRows}) = true
Tables.columns(s::SelectionRows) = Tables.columns(s.selection)
Tables.columnnames(s::SelectionRows) = Tables.columnnames(s.selection)
Tables.getcolumn(s::SelectionRows, i::Int) = Tables.getcolumn(s.selection, i)
Tables.getcolumn(s::SelectionRows, nm::Symbol) = Tables.getcolumn(s.selection, nm)
Tables.materializer(s::SelectionRows) = Tables.materializer(s.selection)
Tables.schema(s::SelectionRows) = Tables.schema(s.selection)

# utils
_nrows(cols) = length(Tables.getcolumn(cols, 1))

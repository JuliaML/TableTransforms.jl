"""
    tablerows(table)

Returns an appropriate iterator for table rows.
The rows are iterable, implement the `Tables.AbstractRow` interface
and the following ways of column access:

```julia
row.colname
row."colname"
row[colindex]
row[:colname]
row["colname"]
```
"""
function tablerows(table)
  if !Tables.istable(table)
    throw(ArgumentError("the argument is not a table"))
  end

  if Tables.rowaccess(table)
    RTableRows(table)
  else
    CTableRows(table)
  end
end

#------------------
# COMMON INTERFACE
#------------------

abstract type TableRow end

# column access
Base.getproperty(row::TableRow, nm::Symbol) = Tables.getcolumn(row, nm)
Base.getproperty(row::TableRow, nm::AbstractString) = Tables.getcolumn(row, Symbol(nm))
Base.getindex(row::TableRow, i::Int) = Tables.getcolumn(row, i)
Base.getindex(row::TableRow, nm::Symbol) = Tables.getcolumn(row, nm)
Base.getindex(row::TableRow, nm::AbstractString) = Tables.getcolumn(row, Symbol(nm))

# iterator interface
Base.length(row::TableRow) = length(Tables.columnnames(row))
Base.iterate(row::TableRow, state::Int=1) = state > length(row) ? nothing : (Tables.getcolumn(row, state), state + 1)

#--------------
# COLUMN TABLE
#--------------

struct CTableRows{T}
  cols::T
  nrows::Int

  function CTableRows(table)
    cols = Tables.columns(table)
    nrows = _nrows(cols)
    new{typeof(cols)}(cols, nrows)
  end
end

# iterator interface
Base.length(rows::CTableRows) = rows.nrows
Base.iterate(rows::CTableRows, state::Int=1) = state > length(rows) ? nothing : (CTableRow(rows.cols, state), state + 1)

struct CTableRow{T} <: TableRow
  cols::T
  ind::Int
end

# getters
getcols(row::CTableRow) = getfield(row, :cols)
getind(row::CTableRow) = getfield(row, :ind)

# AbstractRow interface
Tables.columnnames(row::CTableRow) = Tables.columnnames(getcols(row))
Tables.getcolumn(row::CTableRow, i::Int) = Tables.getcolumn(getcols(row), i)[getind(row)]
Tables.getcolumn(row::CTableRow, nm::Symbol) = Tables.getcolumn(getcols(row), nm)[getind(row)]

#-----------
# ROW TABLE
#-----------

struct RTableRows{T}
  rows::T

  function RTableRows(table)
    rows = Tables.rows(table)
    new{typeof(rows)}(rows)
  end
end

# iterator interface
Base.length(rows::RTableRows) = length(rows.rows)
function Base.iterate(rows::RTableRows, args...)
  next = iterate(rows.rows, args...)
  if isnothing(next)
    nothing
  else
    row, state = next
    (RTableRow(row), state)
  end
end

struct RTableRow{T} <: TableRow
  row::T
end

# getters
getrow(row::RTableRow) = getfield(row, :row)

# AbstractRow interface
Tables.columnnames(row::RTableRow) = Tables.columnnames(getrow(row))
Tables.getcolumn(row::RTableRow, i::Int) = Tables.getcolumn(getrow(row), i)
Tables.getcolumn(row::RTableRow, nm::Symbol) = Tables.getcolumn(getrow(row), nm)

#-------
# UTILS
#-------

function _nrows(cols)
  names = Tables.columnnames(cols)
  isempty(names) && return 0
  column = Tables.getcolumn(cols, first(names))
  length(column)
end

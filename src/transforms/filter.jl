# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Filter(function)

Filters the table returning only the rows where the `function` returns true.
"""
struct Filter{F} <: Stateless
  func::F 
end

isrevertible(::Type{<:Filter}) = true

rowvalues(row, colnames) = [Tables.getcolumn(row, col) for col in colnames]

function apply(transform::Filter, table)
  tablerows = Tables.rows(table)
  colnames = Tables.columnnames(table)
  rows = [rowvalues(row, colnames) for row in tablerows]

  # selected rows and rejected rows/inds 
  srows = Vector{eltype(rows)}()
  rrows = Vector{eltype(rows)}()
  rinds = Vector{Int}()
  
  for (i, row) in enumerate(rows)
    if transform.func(row)
      push!(srows, row)
    else
      push!(rrows, row)
      push!(rinds, i)
    end
  end

  𝒯 = [(; zip(colnames, row)...) for row in srows]
  newtable = 𝒯 |> Tables.materializer(table)
  return newtable, zip(rinds, rrows)
end

function revert(::Filter, newtable, cache)
  tablerows = Tables.rows(newtable)
  colnames = Tables.columnnames(newtable)
  rows = Vector[rowvalues(row, colnames) for row in tablerows]

  for (i, row) in cache
    insert!(rows, i, row)
  end

  𝒯 = [(; zip(colnames, row)...) for row in rows]
  𝒯 |> Tables.materializer(newtable)
end

"""
    DropMissing()

Drop all rows with missing values in table.
"""
DropMissing() = Filter(row -> all(!ismissing, row))

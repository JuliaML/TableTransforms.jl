# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# assert that all columns of table are Continuous
function assert_continuous(table)
  types = schema(table).scitypes
  @assert all(T <: Continuous for T in types) "columns must hold continuous variables"
end

# apply function column by column on table
# assuming that it returns result an cache
function colwise(func, table)
  names = Tables.columnnames(table)
  cols  = Tables.columns(table)

  # function to transform a single column
  function f(n)
    x = Tables.getcolumn(cols, n)
    y, c = func(x)
    (n => y), c
  end

  # parallel map with multiple threads
  vals = foldxt(vcat, Map(f), names)

  # new table with transformed columns
  𝒯 = (; first.(vals)...) |> Tables.materializer(table)

  # cache values for each column
  𝒞 = last.(vals)

  # return new table and cache
  𝒯, 𝒞
end
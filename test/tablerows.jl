@testset "tablerows" begin
  #--------------
  # COLUMN TABLE
  #--------------

  # table rows
  tb = (a=[1, 2, 3], b=[4, 5, 6])
  rows = TT.tablerows(tb)
  @test rows isa TT.CTableRows
  # iterator interface
  @test length(rows) == 3
  row, state = iterate(rows)
  @test row.a == 1
  @test row.b == 4
  row, state = iterate(rows, state)
  @test row.a == 2
  @test row.b == 5
  row, state = iterate(rows, state)
  @test row.a == 3
  @test row.b == 6
  @test isnothing(iterate(rows, state))

  # table row
  row = first(rows)
  @test row isa TT.CTableRow
  # AbstractRow interface
  @test Tables.columnnames(row) == (:a, :b)
  @test Tables.getcolumn(row, 1) == 1
  @test Tables.getcolumn(row, :a) == 1
  # column access
  @test row."a" == 1
  @test row[1] == 1
  @test row[:a] == 1
  @test row["a"] == 1
  # iterator interface
  item, state = iterate(row)
  @test item == 1
  item, state = iterate(row, state)
  @test item == 4
  @test isnothing(iterate(row, state))

  #-----------
  # ROW TABLE
  #-----------

  # table rows
  tb = [(a=1, b=4), (a=2, b=5), (a=3, b=6)]
  rows = TT.tablerows(tb)
  @test rows isa TT.RTableRows
  # iterator interface
  @test length(rows) == 3
  row, state = iterate(rows)
  @test row.a == 1
  @test row.b == 4
  row, state = iterate(rows, state)
  @test row.a == 2
  @test row.b == 5
  row, state = iterate(rows, state)
  @test row.a == 3
  @test row.b == 6
  @test isnothing(iterate(rows, state))

  # table row
  row = first(rows)
  @test row isa TT.RTableRow
  # AbstractRow interface
  @test Tables.columnnames(row) == (:a, :b)
  @test Tables.getcolumn(row, 2) == 4
  @test Tables.getcolumn(row, :b) == 4
  # column access
  @test row."b" == 4
  @test row[2] == 4
  @test row[:b] == 4
  @test row["b"] == 4
  # iterator interface
  item, state = iterate(row)
  @test item == 1
  item, state = iterate(row, state)
  @test item == 4
  @test isnothing(iterate(row, state))
end

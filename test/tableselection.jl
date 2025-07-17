@testset "TableSelection" begin
  a = rand(10)
  b = rand(10)
  c = rand(10)
  d = rand(10)
  e = rand(10)
  f = rand(10)
  t = Table(; a, b, c, d, e, f)

  # Tables.jl interface
  names = [:a, :b, :e]
  s = TT.TableSelection(t, names)
  @test Tables.istable(s) == true
  @test Tables.columnaccess(s) == true
  @test Tables.rowaccess(s) == false
  @test Tables.columns(s) === s
  @test Tables.columnnames(s) == (:a, :b, :e)
  @test Tables.schema(s).names == (:a, :b, :e)
  @test Tables.schema(s).types == (Float64, Float64, Float64)
  @test Tables.materializer(s) == Tables.materializer(t)

  # getcolumn
  cols = Tables.columns(t)
  @test Tables.getcolumn(s, :a) == Tables.getcolumn(cols, :a)
  @test Tables.getcolumn(s, 1) == Tables.getcolumn(cols, 1)
  @test Tables.getcolumn(s, 3) == Tables.getcolumn(cols, :e)

  # row table
  names = [:a, :b, :e]
  rt = Tables.rowtable(t)
  s = TT.TableSelection(rt, names)
  cols = Tables.columns(rt)
  @test Tables.getcolumn(s, :a) == Tables.getcolumn(cols, :a)
  @test Tables.getcolumn(s, 1) == Tables.getcolumn(cols, 1)
  @test Tables.getcolumn(s, 3) == Tables.getcolumn(cols, :e)

  # throws
  @test_throws AssertionError TT.TableSelection(t, [:a, :b, :z])
  @test_throws AssertionError TT.TableSelection(t, [:x, :y, :z])
end

@testset "TableSelection" begin
  a = rand(10)
  b = rand(10)
  c = rand(10)
  d = rand(10)
  e = rand(10)
  f = rand(10)
  t = Table(; a, b, c, d, e, f)

  # Tables.jl interface
  select = [:a, :b, :e]
  newnames = select
  s = TableTransforms.TableSelection(t, newnames, select)
  @test Tables.istable(s) == true
  @test Tables.columnaccess(s) == true
  @test Tables.rowaccess(s) == false
  @test Tables.columns(s) === s
  @test Tables.columnnames(s) == [:a, :b, :e]
  @test Tables.schema(s).names == (:a, :b, :e)
  @test Tables.schema(s).types == (Float64, Float64, Float64)
  @test Tables.materializer(s) == Tables.materializer(t)

  # getcolumn
  cols = Tables.columns(t)
  @test Tables.getcolumn(s, :a) == Tables.getcolumn(cols, :a)
  @test Tables.getcolumn(s, 1) == Tables.getcolumn(cols, 1)
  @test Tables.getcolumn(s, 3) == Tables.getcolumn(cols, :e)

  # selectin with renaming
  select = [:c, :d, :f]
  newnames = [:x, :y, :z]
  s = TableTransforms.TableSelection(t, newnames, select)
  @test Tables.columnnames(s) == [:x, :y, :z]
  @test Tables.getcolumn(s, :x) == t.c
  @test Tables.getcolumn(s, :y) == t.d
  @test Tables.getcolumn(s, :z) == t.f
  @test Tables.getcolumn(s, 1) == t.c
  @test Tables.getcolumn(s, 2) == t.d
  @test Tables.getcolumn(s, 3) == t.f

  # row table
  select = [:a, :b, :e]
  newnames = select
  rt = Tables.rowtable(t)
  s = TableTransforms.TableSelection(rt, newnames, select)
  cols = Tables.columns(rt)
  @test Tables.getcolumn(s, :a) == Tables.getcolumn(cols, :a)
  @test Tables.getcolumn(s, 1) == Tables.getcolumn(cols, 1)
  @test Tables.getcolumn(s, 3) == Tables.getcolumn(cols, :e)

  # throws
  @test_throws AssertionError TableTransforms.TableSelection(t, [:a, :b, :z], [:a, :b, :z])
  @test_throws AssertionError TableTransforms.TableSelection(t, [:x, :y, :z], [:c, :d, :k])
  s = TableTransforms.TableSelection(t, [:a, :b, :e], [:a, :b, :e])
  @test_throws ErrorException Tables.getcolumn(s, :f)
  @test_throws ErrorException Tables.getcolumn(s, 4)
  s = TableTransforms.TableSelection(t, [:x, :y, :z], [:c, :d, :f])
  @test_throws ErrorException Tables.getcolumn(s, :c)
  @test_throws ErrorException Tables.getcolumn(s, 4)
  @test_throws ErrorException Tables.getcolumn(s, -2)
end

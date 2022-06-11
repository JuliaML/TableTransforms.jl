@testset "ColSpec" begin
  vecnames = [:a, :b, :c, :d, :e, :f]
  tupnames = (:a, :b, :c, :d, :e, :f)

  # vector of symbols
  colspec = [:a, :c, :e]
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # tuple of symbols
  colspec = (:a, :c, :e)
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # vector of strings
  colspec = ["a", "c", "e"]
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # tuple of strings
  colspec = ("a", "c", "e")
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # vector of integers
  colspec = [1, 3, 5]
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # tuple of integers
  colspec = (1, 3, 5)
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # regex
  colspec = r"[ace]"
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # colon
  snames = TableTransforms.choose(:, vecnames)
  @test snames == [:a, :b, :c, :d, :e, :f]
  snames = TableTransforms.choose(:, tupnames)
  @test snames == [:a, :b, :c, :d, :e, :f]

  # nothing
  snames = TableTransforms.choose(nothing, vecnames)
  @test snames == Symbol[]
  snames = TableTransforms.choose(nothing, tupnames)
  @test snames == Symbol[]

  # throws
  @test_throws AssertionError TableTransforms.choose(r"x", vecnames)
  @test_throws AssertionError TableTransforms.choose(r"x", tupnames)
  @test_throws AssertionError TableTransforms.choose(String[], vecnames)
  @test_throws AssertionError TableTransforms.choose(String[], tupnames)
  @test_throws AssertionError TableTransforms.choose(Symbol[], vecnames)
  @test_throws AssertionError TableTransforms.choose(Symbol[], tupnames)

  # type stability
  @inferred TableTransforms.choose([:a, :b], vecnames)
  @inferred TableTransforms.choose([:a, :b], tupnames)
  @inferred TableTransforms.choose((:a, :b), vecnames)
  @inferred TableTransforms.choose((:a, :b), tupnames)
  @inferred TableTransforms.choose(["a", "b"], vecnames)
  @inferred TableTransforms.choose(["a", "b"], tupnames)
  @inferred TableTransforms.choose(("a", "b"), vecnames)
  @inferred TableTransforms.choose(("a", "b"), tupnames)
  @inferred TableTransforms.choose([1, 2], vecnames)
  @inferred TableTransforms.choose([1, 2], tupnames)
  @inferred TableTransforms.choose((1, 2), vecnames)
  @inferred TableTransforms.choose((1, 2), tupnames)
  @inferred TableTransforms.choose(r"[ab]", vecnames)
  @inferred TableTransforms.choose(r"[ab]", tupnames)
  @inferred TableTransforms.choose(:, vecnames)
  @inferred TableTransforms.choose(:, tupnames)
end

@testset "TableSelection" begin
  a = rand(4000)
  b = rand(4000)
  c = rand(4000)
  d = rand(4000)
  e = rand(4000)
  f = rand(4000)
  t = Table(; a, b, c, d, e, f)

  # Tables.jl interface
  s = TableTransforms.TableSelection(t, [:a, :b, :e])
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

  # row table
  rt = Tables.rowtable(t)
  s = TableTransforms.TableSelection(rt, [:a, :b, :e])
  cols = Tables.columns(rt)
  @test Tables.getcolumn(s, :a) == Tables.getcolumn(cols, :a)
  @test Tables.getcolumn(s, 1) == Tables.getcolumn(cols, 1)
  @test Tables.getcolumn(s, 3) == Tables.getcolumn(cols, :e)

  # throws
  @test_throws AssertionError TableTransforms.TableSelection(t, [:a, :b, :z])
  s = TableTransforms.TableSelection(t, [:a, :b, :e])
  @test_throws ErrorException Tables.getcolumn(s, :f)
end
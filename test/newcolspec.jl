@testset "ColSpec" begin
  vecnames = [:a, :b, :c, :d, :e, :f]
  tupnames = (:a, :b, :c, :d, :e, :f)

  # vector of symbols
  colspec = TableTransforms.ColSpec([:a, :c, :e])
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # tuple of symbols
  colspec = TableTransforms.ColSpec((:a, :c, :e))
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # vector of strings
  colspec = TableTransforms.ColSpec(["a", "c", "e"])
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # tuple of strings
  colspec = TableTransforms.ColSpec(("a", "c", "e"))
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # vector of integers
  colspec = TableTransforms.ColSpec([1, 3, 5])
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # tuple of integers
  colspec = TableTransforms.ColSpec((1, 3, 5))
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # regex
  colspec = TableTransforms.ColSpec(r"[ace]")
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # colon
  colspec = TableTransforms.ColSpec(:)
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :b, :c, :d, :e, :f]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :b, :c, :d, :e, :f]

  # nothing
  colspec = TableTransforms.ColSpec(nothing)
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == Symbol[]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == Symbol[]

  # throws
  colspec = TableTransforms.ColSpec(r"x")
  @test_throws AssertionError TableTransforms.choose(colspec, vecnames)
  @test_throws AssertionError TableTransforms.choose(colspec, tupnames)
  @test_throws AssertionError TableTransforms.ColSpec(Symbol[])
  @test_throws AssertionError TableTransforms.ColSpec(String[])
  @test_throws AssertionError TableTransforms.ColSpec(Int[])
  @test_throws ArgumentError TableTransforms.ColSpec(())
  @test_throws ArgumentError TableTransforms.ColSpec(missing)

  # type stability
  colspec = TableTransforms.ColSpec([:a, :b])
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
  colspec = TableTransforms.ColSpec((:a, :b))
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
  colspec = TableTransforms.ColSpec(["a", "b"])
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
  colspec = TableTransforms.ColSpec(("a", "b"))
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
  colspec = TableTransforms.ColSpec([1, 2])
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
  colspec = TableTransforms.ColSpec((1, 2))
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
  colspec = TableTransforms.ColSpec(r"[ab]")
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
  colspec = TableTransforms.ColSpec(:)
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
  colspec = TableTransforms.ColSpec(nothing)
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
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
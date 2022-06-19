@testset "ColSpec" begin
  vecnames = [:a, :b, :c, :d, :e, :f]
  tupnames = (:a, :b, :c, :d, :e, :f)

  # vector of symbols
  spec = [:a, :c, :e]
  snames = choose(ColSpec(spec), vecnames)
  @test snames == [:a, :c, :e]
  snames = choose(ColSpec(spec), tupnames)
  @test snames == [:a, :c, :e]

  # tuple of symbols
  spec = (:a, :c, :e)
  snames = choose(ColSpec(spec), vecnames)
  @test snames == [:a, :c, :e]
  snames = choose(ColSpec(spec), tupnames)
  @test snames == [:a, :c, :e]

  # vector of strings
  spec = ["a", "c", "e"]
  snames = choose(ColSpec(spec), vecnames)
  @test snames == [:a, :c, :e]
  snames = choose(ColSpec(spec), tupnames)
  @test snames == [:a, :c, :e]

  # tuple of strings
  spec = ("a", "c", "e")
  snames = choose(ColSpec(spec), vecnames)
  @test snames == [:a, :c, :e]
  snames = choose(ColSpec(spec), tupnames)
  @test snames == [:a, :c, :e]

  # vector of integers
  spec = [1, 3, 5]
  snames = choose(ColSpec(spec), vecnames)
  @test snames == [:a, :c, :e]
  snames = choose(ColSpec(spec), tupnames)
  @test snames == [:a, :c, :e]

  # tuple of integers
  spec = (1, 3, 5)
  snames = choose(ColSpec(spec), vecnames)
  @test snames == [:a, :c, :e]
  snames = choose(ColSpec(spec), tupnames)
  @test snames == [:a, :c, :e]

  # regex
  spec = r"[ace]"
  snames = choose(ColSpec(spec), vecnames)
  @test snames == [:a, :c, :e]
  snames = choose(ColSpec(spec), tupnames)
  @test snames == [:a, :c, :e]

  # colon
  snames = choose(ColSpec(:), vecnames)
  @test snames == [:a, :b, :c, :d, :e, :f]
  snames = choose(ColSpec(:), tupnames)
  @test snames == [:a, :b, :c, :d, :e, :f]

  # nothing
  snames = choose(ColSpec(nothing), vecnames)
  @test snames == Symbol[]
  snames = choose(ColSpec(nothing), tupnames)
  @test snames == Symbol[]

  # throws
  @test_throws AssertionError choose(ColSpec(r"x"), vecnames)
  @test_throws AssertionError choose(ColSpec(r"x"), tupnames)
  @test_throws AssertionError ColSpec(Symbol[])
  @test_throws AssertionError ColSpec(String[])
  @test_throws AssertionError ColSpec(Int[])

  # type stability
  @inferred choose(ColSpec([:a, :b]), vecnames)
  @inferred choose(ColSpec([:a, :b]), tupnames)
  @inferred choose(ColSpec((:a, :b)), vecnames)
  @inferred choose(ColSpec((:a, :b)), tupnames)
  @inferred choose(ColSpec(["a", "b"]), vecnames)
  @inferred choose(ColSpec(["a", "b"]), tupnames)
  @inferred choose(ColSpec(("a", "b")), vecnames)
  @inferred choose(ColSpec(("a", "b")), tupnames)
  @inferred choose(ColSpec([1, 2]), vecnames)
  @inferred choose(ColSpec([1, 2]), tupnames)
  @inferred choose(ColSpec((1, 2)), vecnames)
  @inferred choose(ColSpec((1, 2)), tupnames)
  @inferred choose(ColSpec(r"[ab]"), vecnames)
  @inferred choose(ColSpec(r"[ab]"), tupnames)
  @inferred choose(ColSpec(:), vecnames)
  @inferred choose(ColSpec(:), tupnames)
  @inferred choose(ColSpec(nothing), vecnames)
  @inferred choose(ColSpec(nothing), tupnames)
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
  s = TableSelection(t, [:a, :b, :e])
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
  s = TableSelection(rt, [:a, :b, :e])
  cols = Tables.columns(rt)
  @test Tables.getcolumn(s, :a) == Tables.getcolumn(cols, :a)
  @test Tables.getcolumn(s, 1) == Tables.getcolumn(cols, 1)
  @test Tables.getcolumn(s, 3) == Tables.getcolumn(cols, :e)

  # throws
  @test_throws AssertionError TableSelection(t, [:a, :b, :z])
  s = TableSelection(t, [:a, :b, :e])
  @test_throws ErrorException Tables.getcolumn(s, :f)
end
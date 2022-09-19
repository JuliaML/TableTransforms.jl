@testset "ColSpec" begin
  vecnames = [:a, :b, :c, :d, :e, :f]
  tupnames = (:a, :b, :c, :d, :e, :f)

  # vector of symbols
  colspec = TableTransforms.colspec([:a, :c, :e])
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # tuple of symbols
  colspec = TableTransforms.colspec((:a, :c, :e))
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # vector of strings
  colspec = TableTransforms.colspec(["a", "c", "e"])
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # tuple of strings
  colspec = TableTransforms.colspec(("a", "c", "e"))
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # vector of integers
  colspec = TableTransforms.colspec([1, 3, 5])
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # tuple of integers
  colspec = TableTransforms.colspec((1, 3, 5))
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # regex
  colspec = TableTransforms.colspec(r"[ace]")
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # colon
  colspec = TableTransforms.colspec(:)
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == [:a, :b, :c, :d, :e, :f]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == [:a, :b, :c, :d, :e, :f]

  # nothing
  colspec = TableTransforms.colspec(nothing)
  snames = TableTransforms.choose(colspec, vecnames)
  @test snames == Symbol[]
  snames = TableTransforms.choose(colspec, tupnames)
  @test snames == Symbol[]

  # throws
  colspec = TableTransforms.colspec(r"x")
  @test_throws AssertionError TableTransforms.choose(colspec, vecnames)
  @test_throws AssertionError TableTransforms.choose(colspec, tupnames)
  @test_throws AssertionError TableTransforms.colspec(Symbol[])
  @test_throws AssertionError TableTransforms.colspec(String[])
  @test_throws AssertionError TableTransforms.colspec(Int[])
  @test_throws ArgumentError TableTransforms.colspec(())
  @test_throws ArgumentError TableTransforms.colspec(missing)

  # type stability
  colspec = TableTransforms.colspec([:a, :b])
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
  colspec = TableTransforms.colspec((:a, :b))
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
  colspec = TableTransforms.colspec(["a", "b"])
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
  colspec = TableTransforms.colspec(("a", "b"))
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
  colspec = TableTransforms.colspec([1, 2])
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
  colspec = TableTransforms.colspec((1, 2))
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
  colspec = TableTransforms.colspec(r"[ab]")
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
  colspec = TableTransforms.colspec(:)
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
  colspec = TableTransforms.colspec(nothing)
  @inferred TableTransforms.choose(colspec, vecnames)
  @inferred TableTransforms.choose(colspec, tupnames)
end

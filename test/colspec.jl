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

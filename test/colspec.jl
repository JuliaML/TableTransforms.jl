@testset "ColSpec" begin
  vecnames = [:a, :b, :c, :d, :e, :f]
  tupnames = (:a, :b, :c, :d, :e, :f)

  # vector of symbols
  colspec = TT.colspec([:a, :c, :e])
  snames = TT.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TT.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # tuple of symbols
  colspec = TT.colspec((:a, :c, :e))
  snames = TT.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TT.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # vector of strings
  colspec = TT.colspec(["a", "c", "e"])
  snames = TT.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TT.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # tuple of strings
  colspec = TT.colspec(("a", "c", "e"))
  snames = TT.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TT.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # vector of integers
  colspec = TT.colspec([1, 3, 5])
  snames = TT.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TT.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # tuple of integers
  colspec = TT.colspec((1, 3, 5))
  snames = TT.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TT.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # regex
  colspec = TT.colspec(r"[ace]")
  snames = TT.choose(colspec, vecnames)
  @test snames == [:a, :c, :e]
  snames = TT.choose(colspec, tupnames)
  @test snames == [:a, :c, :e]

  # colon
  colspec = TT.colspec(:)
  snames = TT.choose(colspec, vecnames)
  @test snames == [:a, :b, :c, :d, :e, :f]
  snames = TT.choose(colspec, tupnames)
  @test snames == [:a, :b, :c, :d, :e, :f]

  # nothing
  colspec = TT.colspec(nothing)
  snames = TT.choose(colspec, vecnames)
  @test snames == Symbol[]
  snames = TT.choose(colspec, tupnames)
  @test snames == Symbol[]

  # single symbol
  colspec = TT.colspec(:a)
  snames = TT.choose(colspec, vecnames)
  @test snames == [:a]
  snames = TT.choose(colspec, tupnames)
  @test snames == [:a]

  # single string
  colspec = TT.colspec("b")
  snames = TT.choose(colspec, vecnames)
  @test snames == [:b]
  snames = TT.choose(colspec, tupnames)
  @test snames == [:b]

  # single integer
  colspec = TT.colspec(3)
  snames = TT.choose(colspec, vecnames)
  @test snames == [:c]
  snames = TT.choose(colspec, tupnames)
  @test snames == [:c]

  # throws
  # invalid colspec
  @test_throws ArgumentError TT.colspec(missing)
  # empty selection
  @test_throws ArgumentError TT.colspec(Symbol[])
  @test_throws ArgumentError TT.colspec(String[])
  @test_throws ArgumentError TT.colspec(Int[])
  @test_throws ArgumentError TT.colspec(())
  # regex doesn't match any names in input table
  colspec = TT.colspec(r"x")
  @test_throws AssertionError TT.choose(colspec, vecnames)
  @test_throws AssertionError TT.choose(colspec, tupnames)
  # names not present in input table
  colspec = TT.colspec([:x, :a])
  @test_throws AssertionError TT.choose(colspec, vecnames)
  @test_throws AssertionError TT.choose(colspec, tupnames)

  # type stability
  colspec = TT.colspec([:a, :b])
  @inferred TT.choose(colspec, vecnames)
  @inferred TT.choose(colspec, tupnames)
  colspec = TT.colspec((:a, :b))
  @inferred TT.choose(colspec, vecnames)
  @inferred TT.choose(colspec, tupnames)
  colspec = TT.colspec(["a", "b"])
  @inferred TT.choose(colspec, vecnames)
  @inferred TT.choose(colspec, tupnames)
  colspec = TT.colspec(("a", "b"))
  @inferred TT.choose(colspec, vecnames)
  @inferred TT.choose(colspec, tupnames)
  colspec = TT.colspec([1, 2])
  @inferred TT.choose(colspec, vecnames)
  @inferred TT.choose(colspec, tupnames)
  colspec = TT.colspec((1, 2))
  @inferred TT.choose(colspec, vecnames)
  @inferred TT.choose(colspec, tupnames)
  colspec = TT.colspec(r"[ab]")
  @inferred TT.choose(colspec, vecnames)
  @inferred TT.choose(colspec, tupnames)
  colspec = TT.colspec(:)
  @inferred TT.choose(colspec, vecnames)
  @inferred TT.choose(colspec, tupnames)
  colspec = TT.colspec(nothing)
  @inferred TT.choose(colspec, vecnames)
  @inferred TT.choose(colspec, tupnames)
  colspec = TT.colspec(:a)
  @inferred TT.choose(colspec, vecnames)
  @inferred TT.choose(colspec, tupnames)
  colspec = TT.colspec("b")
  @inferred TT.choose(colspec, vecnames)
  @inferred TT.choose(colspec, tupnames)
  colspec = TT.colspec(3)
  @inferred TT.choose(colspec, vecnames)
  @inferred TT.choose(colspec, tupnames)
end

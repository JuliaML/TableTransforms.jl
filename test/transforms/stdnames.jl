@testset "StdNames" begin
  names = ["apple banana", "apple\tbanana", "apple_banana", "apple-banana", "apple_Banana"]
  for name in names
    @test TableTransforms._camel(name) == "AppleBanana"
    @test TableTransforms._snake(name) == "apple_banana"
    @test TableTransforms._upper(name) == "APPLEBANANA"
  end

  names = ["a", "A", "_a", "_A", "a ", "A "]
  for name in names
    @test TableTransforms._camel(name) == "A"
    @test TableTransforms._snake(name) == "a"
    @test TableTransforms._upper(name) == "A"
  end

  # special characters
  name = "a&B"
  @test TableTransforms._clean(name) == "aB"

  name = "apple#"
  @test TableTransforms._clean(name) == "apple"

  name = "apple-tree"
  @test TableTransforms._clean(name) == "apple-tree"

  # invariance test
  names = ["AppleTree", "BananaFruit", "PearSeed"]
  for name in names
    @test TableTransforms._camel(name) == name
  end

  names = ["apple_tree", "banana_fruit", "pear_seed"]
  for name in names
    @test TableTransforms._snake(name) == name
  end

  names = ["APPLETREE", "BANANAFRUIT", "PEARSEED"]
  for name in names
    @test TableTransforms._upper(name) == name
  end

  # uniqueness test
  names = (Symbol("AppleTree"), Symbol("apple tree"), Symbol("apple_tree"))
  cols = ([1, 2, 3], [4, 5, 6], [7, 8, 9])
  t = Table(; zip(names, cols)...)
  rt = Tables.rowtable(t)
  T = StdNames(:upper)
  n, c = apply(T, rt)
  columns = Tables.columns(n)
  columnnames = Tables.columnnames(columns)
  @test columnnames == (:APPLETREE, :APPLETREE_, :APPLETREE__)

  # row table test
  names = (:a, Symbol("apple tree"), Symbol("banana tree"))
  cols = ([1, 2, 3], [4, 5, 6], [7, 8, 9])
  t = Table(; zip(names, cols)...)
  rt = Tables.rowtable(t)
  T = StdNames()
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  @test isrevertible(T)
  rtₒ = revert(T, n, c)
  @test rt == rtₒ

  # reapply test
  T = StdNames()
  n1, c1 = apply(T, rt)
  n2 = reapply(T, n1, c1)
  @test n1 == n2
end

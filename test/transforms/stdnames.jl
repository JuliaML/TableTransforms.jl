@testset "StdNames" begin
  names = Symbol.(["_apple tree_", " banana-fruit ", "-pear\tseed-"])
  columns = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  t = Table(; zip(names, columns)...)
  T = StdNames(:uppersnake)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:APPLE_TREE, :BANANA_FRUIT, :PEAR_SEED)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = StdNames(:uppercamel)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:AppleTree, :BananaFruit, :PearSeed)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = StdNames(:upperflat)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:APPLETREE, :BANANAFRUIT, :PEARSEED)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = StdNames(:snake)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:apple_tree, :banana_fruit, :pear_seed)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = StdNames(:camel)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:appleTree, :bananaFruit, :pearSeed)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = StdNames(:flat)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:appletree, :bananafruit, :pearseed)
  tₒ = revert(T, n, c)
  @test t == tₒ

  # internal functions
  names = ["apple banana", "apple\tbanana", "apple_banana", "apple-banana", "apple_Banana"]
  for name in names
    @test TT._uppersnake(name) == "APPLE_BANANA"
    @test TT._uppercamel(name) == "AppleBanana"
    @test TT._upperflat(name) == "APPLEBANANA"
    @test TT._snake(name) == "apple_banana"
    @test TT._camel(name) == "appleBanana"
    @test TT._flat(name) == "applebanana"
  end

  names = ["a", "A", "_a", "_A", "a ", "A "]
  for name in names
    @test TT._uppersnake(TT._clean(name)) == "A"
    @test TT._uppercamel(TT._clean(name)) == "A"
    @test TT._upperflat(TT._clean(name)) == "A"
    @test TT._snake(TT._clean(name)) == "a"
    @test TT._camel(TT._clean(name)) == "a"
    @test TT._flat(TT._clean(name)) == "a"
  end

  # special characters
  name = "a&B"
  @test TT._clean(name) == "aB"

  name = "apple#"
  @test TT._clean(name) == "apple"

  name = "apple-tree"
  @test TT._clean(name) == "apple-tree"

  # invariance test
  names = ["APPLE_TREE", "BANANA_FRUIT", "PEAR_SEED"]
  for name in names
    @test TT._isuppersnake(name)
    @test TT._uppersnake(name) == name
  end

  names = ["AppleTree", "BananaFruit", "PearSeed"]
  for name in names
    @test TT._isuppercamel(name)
    @test TT._uppercamel(name) == name
  end

  names = ["APPLETREE", "BANANAFRUIT", "PEARSEED"]
  for name in names
    @test TT._isupperflat(name)
    @test TT._upperflat(name) == name
  end

  names = ["apple_tree", "banana_fruit", "pear_seed"]
  for name in names
    @test TT._issnake(name)
    @test TT._snake(name) == name
  end

  names = ["appleTree", "bananaFruit", "pearSeed"]
  for name in names
    @test TT._iscamel(name)
    @test TT._camel(name) == name
  end

  names = ["appletree", "bananafruit", "pearseed"]
  for name in names
    @test TT._isflat(name)
    @test TT._flat(name) == name
  end

  # uniqueness test
  names = (Symbol("AppleTree"), Symbol("apple tree"), Symbol("apple_tree"))
  columns = ([1, 2, 3], [4, 5, 6], [7, 8, 9])
  t = Table(; zip(names, columns)...)
  rt = Tables.rowtable(t)
  T = StdNames(:upperflat)
  n, c = apply(T, rt)
  @test Tables.schema(n).names == (:APPLETREE, :APPLETREE_, :APPLETREE__)

  # row table test
  names = (:a, Symbol("apple tree"), Symbol("banana tree"))
  columns = ([1, 2, 3], [4, 5, 6], [7, 8, 9])
  t = Table(; zip(names, columns)...)
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

  # throws
  @test_throws ArgumentError StdNames(:test)
end

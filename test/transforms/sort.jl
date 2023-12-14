@testset "Sort" begin
  @test !isrevertible(Sort(:a))

  a = [5, 3, 1, 2]
  b = [2, 4, 8, 5]
  c = [3, 2, 1, 4]
  d = [4, 3, 7, 5]
  t = Table(; a, b, c, d)

  T = Sort(:a)
  n, c = apply(T, t)
  @test Tables.schema(t) == Tables.schema(n)
  @test n.a == [1, 2, 3, 5]
  @test n.b == [8, 5, 4, 2]
  @test n.c == [1, 4, 2, 3]
  @test n.d == [7, 5, 3, 4]

  # descending order test
  T = Sort(:b, rev=true)
  n, c = apply(T, t)
  @test Tables.schema(t) == Tables.schema(n)
  @test n.a == [1, 2, 3, 5]
  @test n.b == [8, 5, 4, 2]
  @test n.c == [1, 4, 2, 3]
  @test n.d == [7, 5, 3, 4]

  # random test
  a = rand(10)
  b = rand(10)
  c = rand(10)
  d = rand(10)
  t = Table(; a, b, c, d)

  T = Sort(:c)
  n, c = apply(T, t)

  @test Tables.schema(t) == Tables.schema(n)
  @test issetequal(Tables.rowtable(t), Tables.rowtable(n))
  @test issorted(Tables.getcolumn(n, :c))

  # sort by multiple columns
  a = [-2, -1, -2, 2, 1, -1, 1, 2]
  b = [-8, -4, 6, 9, 8, 2, 2, -8]
  c = [-3, 6, 5, 4, -8, -7, -1, -10]
  t = Table(; a, b, c)

  T = Sort(1, 2)
  n, c = apply(T, t)
  @test n.a == [-2, -2, -1, -1, 1, 1, 2, 2]
  @test n.b == [-8, 6, -4, 2, 2, 8, -8, 9]
  @test n.c == [-3, 5, 6, -7, -1, -8, -10, 4]

  T = Sort([:a, :c], rev=true)
  n, c = apply(T, t)
  @test n.a == [2, 2, 1, 1, -1, -1, -2, -2]
  @test n.b == [9, -8, 2, 8, -4, 2, 6, -8]
  @test n.c == [4, -10, -1, -8, 6, -7, 5, -3]

  T = Sort(("b", "c"), by=row -> abs.(row))
  n, c = apply(T, t)
  @test n.a == [1, -1, -1, -2, -2, 1, 2, 2]
  @test n.b == [2, 2, -4, 6, -8, 8, -8, 9]
  @test n.c == [-1, -7, 6, 5, -3, -8, -10, 4]

  # throws: Sort without arguments
  @test_throws ArgumentError Sort()

  # throws: empty selection
  @test_throws ArgumentError Sort(())
  @test_throws ArgumentError Sort(Symbol[])
  @test_throws ArgumentError Sort(String[])

  # throws: regex doesn't match any names in input table
  @test_throws AssertionError apply(Sort(r"x"), t)

  # throws: columns that do not exist in the original table
  @test_throws AssertionError apply(Sort([:d, :e]), t)
  @test_throws AssertionError apply(Sort(("d", "e")), t)

  # Invalid kwarg
  @test_throws MethodError apply(Sort(:a, :b, test=1), t)
end

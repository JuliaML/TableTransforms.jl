@testset "Rename" begin
  a = rand(10)
  b = rand(10)
  c = rand(10)
  d = rand(10)
  t = Table(; a, b, c, d)

  # integer => symbol
  T = Rename(1 => :x, 3 => :y)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:x, :b, :y, :d)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Rename(2 => :x, 4 => :y)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a, :x, :c, :y)
  tₒ = revert(T, n, c)
  @test t == tₒ

  # integer => string
  T = Rename(1 => "x", 3 => "y")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:x, :b, :y, :d)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Rename(2 => "x", 4 => "y")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a, :x, :c, :y)
  tₒ = revert(T, n, c)
  @test t == tₒ

  # symbol = symbol
  T = Rename(:a => :x)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:x, :b, :c, :d)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Rename(:a => :x, :c => :y)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:x, :b, :y, :d)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Rename(:b => :x, :d => :y)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a, :x, :c, :y)
  tₒ = revert(T, n, c)
  @test t == tₒ

  # symbol => string
  T = Rename(:a => "x", :c => "y")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:x, :b, :y, :d)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Rename(:b => "x", :d => "y")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a, :x, :c, :y)
  tₒ = revert(T, n, c)
  @test t == tₒ

  # string => symbol
  T = Rename("a" => :x)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:x, :b, :c, :d)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Rename("a" => :x, "c" => :y)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:x, :b, :y, :d)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Rename("b" => :x, "d" => :y)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a, :x, :c, :y)
  tₒ = revert(T, n, c)
  @test t == tₒ

  # string => string
  T = Rename("a" => "x", "c" => "y")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:x, :b, :y, :d)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Rename("b" => "x", "d" => "y")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a, :x, :c, :y)
  tₒ = revert(T, n, c)
  @test t == tₒ

  # row table
  rt = Tables.rowtable(t)
  T = Rename(:a => :x, :c => :y)
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  rtₒ = revert(T, n, c)
  @test rt == rtₒ

  # reapply test
  T = Rename(:b => :x, :d => :y)
  n1, c1 = apply(T, t)
  n2 = reapply(T, t, c1)
  @test n1 == n2

  # vector of pairs
  T = Rename([1 => :x, 3 => :y])
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:x, :b, :y, :d)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Rename([2, 4] .=> ["x", "y"])
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :x, :c, :y)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Rename([:a => :x, :c => :y])
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:x, :b, :y, :d)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Rename([:b, :d] .=> ["x", "y"])
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :x, :c, :y)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Rename(["a" => :x, "c" => :y])
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:x, :b, :y, :d)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Rename(["b", "d"] .=> ["x", "y"])
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :x, :c, :y)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Rename(nm -> nm * "_test")
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a_test, :b_test, :c_test, :d_test)
  tₒ = revert(T, n, c)
  @test t == tₒ

  # error: cannot create Rename transform without arguments
  @test_throws ArgumentError Rename()
  # error: new names must be unique
  @test_throws AssertionError Rename(:a => :x, :b => :x)
  @test_throws AssertionError apply(Rename(:a => :c, :b => :d), t)
end

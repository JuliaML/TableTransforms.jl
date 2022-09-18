@testset "Rename" begin
  a = rand(4000)
  b = rand(4000)
  c = rand(4000)
  d = rand(4000)
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

  # throws
  @test_throws AssertionError Rename(:a => :x, :b => :x)
  @test_throws AssertionError apply(Rename(:a => :c, :b => :d), t)
end

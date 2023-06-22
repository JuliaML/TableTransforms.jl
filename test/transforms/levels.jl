@testset "Levels" begin
  a = categorical(rand([true, false], 50))
  b = categorical(rand(["y", "n"], 50))
  c = categorical(rand(1:3, 50))
  t = Table(; a, b, c)

  T = Levels(2 => ["n", "y", "m"])
  n, c = apply(T, t)
  @test levels(n.b) == ["n", "y", "m"]
  @test isordered(n.b) == false
  tₒ = revert(T, n, c)
  @test tₒ == t

  T = Levels(:b => ["n", "y", "m"], :c => 1:4, ordered=[:c])
  n, c = apply(T, t)
  @test levels(n.b) == ["n", "y", "m"]
  @test isordered(n.b) == false
  @test levels(n.c) == [1, 2, 3, 4]
  @test isordered(n.c) == true
  tₒ = revert(T, n, c)
  @test tₒ == t

  T = Levels("b" => ["n", "y", "m"], "c" => 1:4, ordered=["b"])
  n, c = apply(T, t)
  @test levels(n.b) == ["n", "y", "m"]
  @test isordered(n.b) == true
  @test levels(n.c) == [1, 2, 3, 4]
  @test isordered(n.c) == false
  tₒ = revert(T, n, c)
  @test tₒ == t

  a = categorical(["yes", "no", "no", "no", "yes"])
  b = categorical([1, 2, 4, 2, 8], ordered=false)
  c = categorical([1, 2, 1, 2, 1])
  d = categorical([1, 23, 5, 7, 7])
  e = categorical([2, 3, 1, 4, 1])
  t = Table(; a, b, c, d, e)

  T = Levels(:a => ["yes", "no"], :c => [1, 2, 4], :d => [1, 23, 5, 7], :e => 1:5)
  n, c = apply(T, t)
  @test levels(n.a) == ["yes", "no"]
  @test levels(n.c) == [1, 2, 4]
  @test levels(n.d) == [1, 23, 5, 7]
  @test levels(n.e) == [1, 2, 3, 4, 5]
  tₒ = revert(T, n, c)
  @test levels(tₒ.a) == ["no", "yes"]
  @test levels(tₒ.c) == [1, 2]
  @test levels(tₒ.e) == [1, 2, 3, 4]

  T = Levels("a" => ["yes", "no"], "c" => [1, 2, 4])
  n, c = apply(T, t)
  @test levels(n.a) == ["yes", "no"]
  @test levels(n.c) == [1, 2, 4]
  tₒ = revert(T, n, c)
  @test levels(tₒ.a) == ["no", "yes"]
  @test levels(tₒ.c) == [1, 2]

  T = Levels(:a => ["yes", "no"], :c => [1, 2, 4], :d => [1, 23, 5, 7])
  n, c = apply(T, t)
  @test levels(n.a) == ["yes", "no"]
  @test levels(n.c) == [1, 2, 4]
  @test levels(n.d) == [1, 23, 5, 7]
  tₒ = revert(T, n, c)
  @test levels(tₒ.a) == ["no", "yes"]
  @test levels(tₒ.c) == [1, 2]

  T = Levels("a" => ["yes", "no"], "c" => [1, 2, 4], "e" => 5:-1:1, ordered=["e"])
  n, c = apply(T, t)
  @test levels(n.a) == ["yes", "no"]
  @test levels(n.c) == [1, 2, 4]
  @test levels(n.e) == [5, 4, 3, 2, 1]
  @test isordered(n.a) == false
  @test isordered(n.c) == false
  @test isordered(n.e) == true
  tₒ = revert(T, n, c)
  @test levels(tₒ.e) == [1, 2, 3, 4]
  @test isordered(tₒ.e) == false

  T = Levels(:a => ["yes", "no"], :c => [1, 2, 4], :d => [1, 23, 5, 7], ordered=[:a, :d])
  n, c = apply(T, t)
  @test levels(n.a) == ["yes", "no"]
  @test levels(n.c) == [1, 2, 4]
  @test levels(n.d) == [1, 23, 5, 7]
  @test isordered(n.a) == true
  @test isordered(n.c) == false
  @test isordered(n.d) == true
  tₒ = revert(T, n, c)
  @test isordered(tₒ.a) == false

  a = rand([true, false], 50)
  b = categorical(rand(["y", "n"], 50))
  c = categorical(rand(1:3, 50))
  t = Table(; a, b, c)

  # throws: Levels without arguments
  @test_throws ArgumentError Levels()

  # throws: columns that do not exist in the original table
  T = Levels(:x => ["n", "y", "m"], :y => 1:4)
  @test_throws AssertionError apply(T, t)
  T = Levels("x" => ["n", "y", "m"], "y" => 1:4)
  @test_throws AssertionError apply(T, t)

  # throws: non categorical column
  T = Levels(:a => [true, false], ordered=[:a])
  @test_throws AssertionError apply(T, t)

  # throws: invalid ordered column selection
  T = Levels(:b => ["n", "y", "m"], :c => 1:4, ordered=[:a])
  @test_throws AssertionError apply(T, t)
  T = Levels("b" => ["n", "y", "m"], "c" => 1:4, ordered=["a"])
  @test_throws AssertionError apply(T, t)
  T = Levels("b" => ["n", "y", "m"], "c" => 1:4, ordered=r"xy")
  @test_throws AssertionError apply(T, t)
end

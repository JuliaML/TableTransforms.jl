@testset "Functional" begin
  x = rand(0:0.001:1, 100)
  y = rand(0:0.001:1, 100)
  t = Table(; x, y)
  T = Functional(exp)
  n, c = apply(T, t)
  @test all(x -> 1 ≤ x ≤ ℯ, n.x)
  @test all(y -> 1 ≤ y ≤ ℯ, n.y)
  tₒ = revert(T, n, c)
  @test Tables.matrix(tₒ) ≈ Tables.matrix(t)

  x = rand(1:0.001:ℯ, 100)
  y = rand(1:0.001:ℯ, 100)
  t = Table(; x, y)
  T = Functional(log)
  n, c = apply(T, t)
  @test all(x -> 0 ≤ x ≤ 1, n.x)
  @test all(y -> 0 ≤ y ≤ 1, n.y)
  tₒ = revert(T, n, c)
  @test Tables.matrix(tₒ) ≈ Tables.matrix(t)

  # identity
  x = rand(100)
  y = x + rand(100)
  t = Table(; x, y)

  T = Functional(identity)
  n, c = apply(T, t)
  @test t == n
  tₒ = revert(T, n, c)
  @test tₒ == t

  T = Functional(x -> x)
  n, c = apply(T, t)
  @test t == n
  @test !isrevertible(T)

  # functor tests
  x = rand(100)
  y = rand(100)
  t = Table(; x, y)
  f = Polynomial(1, 2, 3) # f(x) = 1 + 2x + 3x²
  T = Functional(f)
  n, c = apply(T, t)
  @test f.(x) == n.x
  @test f.(y) == n.y
  @test all(≥(1), n.x)
  @test all(≥(1), n.y)
  @test !isrevertible(T)

  # apply functions to specific columns
  x = rand(0:0.001:1, 100)
  y = rand(1:0.001:ℯ, 100)
  z = x + y
  t = Table(; x, y, z)

  T = Functional(1 => exp, 2 => log)
  n, c = apply(T, t)
  @test all(x -> 1 ≤ x ≤ ℯ, n.x)
  @test all(y -> 0 ≤ y ≤ 1, n.y)
  @test t.z == n.z
  tₒ = revert(T, n, c)
  @test Tables.matrix(tₒ) ≈ Tables.matrix(t)

  T = Functional(:x => exp, :y => log)
  n, c = apply(T, t)
  @test all(x -> 1 ≤ x ≤ ℯ, n.x)
  @test all(y -> 0 ≤ y ≤ 1, n.y)
  @test t.z == n.z
  tₒ = revert(T, n, c)
  @test Tables.matrix(tₒ) ≈ Tables.matrix(t)

  T = Functional("x" => exp, "y" => log)
  n, c = apply(T, t)
  @test all(x -> 1 ≤ x ≤ ℯ, n.x)
  @test all(y -> 0 ≤ y ≤ 1, n.y)
  @test t.z == n.z
  tₒ = revert(T, n, c)
  @test Tables.matrix(tₒ) ≈ Tables.matrix(t)

  T = Functional(1 => log, 2 => exp)
  @test isrevertible(T)
  T = Functional(:x => log, :y => exp)
  @test isrevertible(T)
  T = Functional("x" => log, "y" => exp)
  @test isrevertible(T)
  T = Functional(1 => abs, 2 => log)
  @test !isrevertible(T)
  T = Functional(:x => abs, :y => log)
  @test !isrevertible(T)
  T = Functional("x" => abs, "y" => log)
  @test !isrevertible(T)

  # row table
  x = rand(0:0.001:1, 100)
  y = rand(0:0.001:1, 100)
  t = Table(; x, y)
  rt = Tables.rowtable(t)
  T = Functional(exp)
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  rtₒ = revert(T, n, c)
  @test Tables.matrix(rtₒ) ≈ Tables.matrix(rt)

  # throws
  @test_throws ArgumentError Functional()
  t = Table(x=rand(15), y=rand(15))
  T = Functional(Polynomial(1, 2, 3))
  n, c = apply(T, t)
  @test_throws AssertionError revert(T, n, c)
  T = Functional(:x => abs, :y => log)
  n, c = apply(T, t)
  @test_throws AssertionError revert(T, n, c)
end

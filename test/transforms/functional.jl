@testset "Functional" begin
  x = π * rand(100)
  y = π * rand(100)
  t = Table(; x, y)
  T = Functional(cos)
  n, c = apply(T, t)
  @test all(x -> -1 ≤ x ≤ 1, n.x)
  @test all(y -> -1 ≤ y ≤ 1, n.y)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  x = 2 * (rand(100) .- 0.5)
  y = 2 * (rand(100) .- 0.5)
  t = Table(; x, y)
  T = Functional(acos)
  n, c = apply(T, t)
  @test all(x -> 0 ≤ x ≤ π, n.x)
  @test all(y -> 0 ≤ y ≤ π, n.y)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  x = π * (rand(100) .- 0.5)
  y = π * (rand(100) .- 0.5)
  t = Table(; x, y)
  T = Functional(sin)
  n, c = apply(T, t)
  @test all(x -> -1 ≤ x ≤ 1, n.x)
  @test all(y -> -1 ≤ y ≤ 1, n.y)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  x = 2 * (rand(100) .- 0.5)
  y = 2 * (rand(100) .- 0.5)
  t = Table(; x, y)
  T = Functional(asin)
  n, c = apply(T, t)
  @test all(x -> -π / 2 ≤ x ≤ π / 2, n.x)
  @test all(y -> -π / 2 ≤ y ≤ π / 2, n.y)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  x = rand(Normal(0, 25), 100)
  y = x + rand(Normal(10, 2), 100)
  t = Table(; x, y)
  T = Functional(exp)
  n, c = apply(T, t)
  @test all(>(0), n.x)
  @test all(>(0), n.y)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  x = rand(Normal(0, 25), 100)
  y = x + rand(Normal(10, 2), 100)
  t = Table(; x, y)
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
  x = π * rand(100)
  y = 2 * (rand(100) .- 0.5)
  z = x + y
  t = Table(; x, y, z)
  T = Functional(1 => cos, 2 => acos)
  n, c = apply(T, t)
  @test all(x -> -1 ≤ x ≤ 1, n.x)
  @test all(y -> 0 ≤ y ≤ π, n.y)
  @test t.z == n.z
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  x = π * rand(100)
  y = π * (rand(100) .- 0.5)
  z = x + y
  t = Table(; x, y, z)
  T = Functional(:x => cos, :y => sin)
  n, c = apply(T, t)
  @test all(x -> -1 ≤ x ≤ 1, n.x)
  @test all(y -> -1 ≤ y ≤ 1, n.y)
  @test t.z == n.z
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  x = 2 * (rand(100) .- 0.5)
  y = 2 * (rand(100) .- 0.5)
  z = x + y
  t = Table(; x, y, z)
  T = Functional("x" => acos, "y" => asin)
  n, c = apply(T, t)
  @test all(x -> 0 ≤ x ≤ π, n.x)
  @test all(y -> -π / 2 ≤ y ≤ π / 2, n.y)
  @test t.z == n.z
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  T = Functional(1 => cos, 2 => sin)
  @test isrevertible(T)
  T = Functional(:x => cos, :y => sin)
  @test isrevertible(T)
  T = Functional("x" => cos, "y" => sin)
  @test isrevertible(T)
  T = Functional(1 => abs, 2 => sin)
  @test !isrevertible(T)
  T = Functional(:x => abs, :y => sin)
  @test !isrevertible(T)
  T = Functional("x" => abs, "y" => sin)
  @test !isrevertible(T)

  # row table
  x = π * rand(100)
  y = π * rand(100)
  t = Table(; x, y)
  rt = Tables.rowtable(t)
  T = Functional(cos)
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  rtₒ = revert(T, n, c)
  @test Tables.matrix(rt) ≈ Tables.matrix(rtₒ)

  # throws
  @test_throws ArgumentError Functional()
  t = Table(x=rand(15), y=rand(15))
  T = Functional(Polynomial(1, 2, 3))
  n, c = apply(T, t)
  @test_throws AssertionError revert(T, n, c)
  T = Functional(:x => abs, :y => sin)
  n, c = apply(T, t)
  @test_throws AssertionError revert(T, n, c)
end

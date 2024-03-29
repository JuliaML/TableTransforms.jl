@testset "LowHigh" begin
  @test TT.parameters(LowHigh(:a)) == (low=0.25, high=0.75)

  # constant column
  x = fill(3.0, 10)
  y = rand(10)
  t = Table(; x, y)
  T = MinMax()
  n, c = apply(T, t)
  @test n.x == x
  @test n.y != y
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  x = rand(rng, Normal(4, 3), 4000)
  y = rand(rng, Normal(7, 5), 4000)
  t = Table(; x, y)
  T = LowHigh(low=0, high=1)
  n, c = apply(T, t)
  @test all(≤(1), n.x)
  @test all(≥(0), n.x)
  @test all(≤(1), n.y)
  @test all(≥(0), n.y)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  # row table
  rt = Tables.rowtable(t)
  T = LowHigh()
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  rtₒ = revert(T, n, c)
  @test Tables.matrix(rt) ≈ Tables.matrix(rtₒ)

  # columntype does not change
  for FT in (Float16, Float32)
    t = Table(; x=rand(FT, 10))
    for T in (MinMax(), Interquartile(), LowHigh(low=0, high=0.5))
      n, c = apply(T, t)
      @test Tables.columntype(t, :x) == Tables.columntype(n, :x)
      tₒ = revert(T, n, c)
      @test Tables.columntype(t, :x) == Tables.columntype(tₒ, :x)
    end
  end

  # colspec
  z = x + y
  t = Table(; x, y, z)

  T = LowHigh(1, 2, low=0, high=1)
  n, c = apply(T, t)
  @test all(≤(1), n.x)
  @test all(≥(0), n.x)
  @test all(≤(1), n.y)
  @test all(≥(0), n.y)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  T = LowHigh([:x, :y], low=0, high=1)
  n, c = apply(T, t)
  @test all(≤(1), n.x)
  @test all(≥(0), n.x)
  @test all(≤(1), n.y)
  @test all(≥(0), n.y)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  T = LowHigh(("x", "y"), low=0, high=1)
  n, c = apply(T, t)
  @test all(≤(1), n.x)
  @test all(≥(0), n.x)
  @test all(≤(1), n.y)
  @test all(≥(0), n.y)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  T = LowHigh(r"[xy]", low=0, high=1)
  n, c = apply(T, t)
  @test all(≤(1), n.x)
  @test all(≥(0), n.x)
  @test all(≤(1), n.y)
  @test all(≥(0), n.y)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)
end

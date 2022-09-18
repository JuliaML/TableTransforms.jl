@testset "Scale" begin
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
  T = Scale(low=0, high=1)
  n, c = apply(T, t)
  @test all(≤(1), n.x)
  @test all(≥(0), n.x)
  @test all(≤(1), n.y)
  @test all(≥(0), n.y)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  # visual tests   
  if visualtests
    p₁ = scatter(t.x, t.y, label="Original")
    p₂ = scatter(n.x, n.y, label="Scale")
    p = plot(p₁, p₂, layout=(1,2))

    @test_reference joinpath(datadir, "scale.png") p
  end

  # row table
  rt = Tables.rowtable(t)
  T = Scale()
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  rtₒ = revert(T, n, c)
  @test Tables.matrix(rt) ≈ Tables.matrix(rtₒ)

  # columntype does not change
  for FT in (Float16, Float32)
    t = Table(; x=rand(FT, 10))
    for T in (MinMax(), Scale(FT(0), FT(0.5)))
      n, c = apply(T, t)
      @test Tables.columntype(t, :x) == Tables.columntype(n, :x)
      tₒ = revert(T, n, c)
      @test Tables.columntype(t, :x) == Tables.columntype(tₒ, :x)
    end
  end
end

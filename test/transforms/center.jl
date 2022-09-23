@testset "Center" begin
  x = rand(rng, Normal(2, 1), 4000)
  y = rand(rng, Normal(5, 1), 4000)
  t = Table(; x, y)
  T = Center()
  n, c = apply(T, t)
  μ = mean(Tables.matrix(n), dims=1)
  @test isapprox(μ[1], 0; atol=1e-6)
  @test isapprox(μ[2], 0; atol=1e-6)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  # visual tests    
  if visualtests
    p₁ = scatter(t.x, t.y, label="Original")
    p₂ = scatter(n.x, n.y, label="Center")
    p = plot(p₁, p₂, layout=(1,2))

    @test_reference joinpath(datadir, "center.png") p
  end

  # row table
  rt = Tables.rowtable(t)
  T = Center()
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  rtₒ = revert(T, n, c)
  @test Tables.matrix(rt) ≈ Tables.matrix(rtₒ)

  # colspec
  z = x + y
  t = Table(; x, y, z)

  T = Center(1, 2)
  n, c = apply(T, t)
  μ = mean(Tables.matrix(n), dims=1)
  @test isapprox(μ[1], 0; atol=1e-6)
  @test isapprox(μ[2], 0; atol=1e-6)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  T = Center([:x, :y])
  n, c = apply(T, t)
  μ = mean(Tables.matrix(n), dims=1)
  @test isapprox(μ[1], 0; atol=1e-6)
  @test isapprox(μ[2], 0; atol=1e-6)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  T = Center(("x", "y"))
  n, c = apply(T, t)
  μ = mean(Tables.matrix(n), dims=1)
  @test isapprox(μ[1], 0; atol=1e-6)
  @test isapprox(μ[2], 0; atol=1e-6)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  T = Center(r"[xy]")
  n, c = apply(T, t)
  μ = mean(Tables.matrix(n), dims=1)
  @test isapprox(μ[1], 0; atol=1e-6)
  @test isapprox(μ[2], 0; atol=1e-6)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)
end

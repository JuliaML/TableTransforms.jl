@testset "ProjectionPursuit" begin
  N = 100_000
  a = [2randn(rng, N÷2) .+ 6; randn(rng, N÷2)]
  b = [3randn(rng, N÷2); 2randn(rng, N÷2)]
  c = randn(rng, N)
  d = c .+ 0.6randn(rng, N)
  t = (; a, b, c, d)
  
  T = ProjectionPursuit(rng=MersenneTwister(2))
  n, c = apply(T, t)

  @test Tables.columnnames(n) == (:a, :b, :c, :d)
  
  μ = mean(Tables.matrix(n), dims=1)
  @test isapprox(μ[1], 0; atol=1e-4)
  @test isapprox(μ[2], 0; atol=1e-4)
  @test isapprox(μ[3], 0; atol=1e-4)
  @test isapprox(μ[4], 0; atol=1e-4)

  Σ = cov(Tables.matrix(n))
  @test isapprox(Σ[1,2], 0; atol=1e-3)
  @test isapprox(Σ[1,3], 0; atol=1e-3)
  @test isapprox(Σ[1,4], 0; atol=1e-3)
  @test isapprox(Σ[2,1], 0; atol=1e-3)
  @test isapprox(Σ[2,3], 0; atol=1e-3)
  @test isapprox(Σ[2,4], 0; atol=1e-3)
  @test isapprox(Σ[3,1], 0; atol=1e-3)
  @test isapprox(Σ[3,2], 0; atol=1e-3)
  @test isapprox(Σ[3,4], 0; atol=1e-3)
  @test isapprox(Σ[4,1], 0; atol=1e-3)
  @test isapprox(Σ[4,2], 0; atol=1e-3)
  @test isapprox(Σ[4,3], 0; atol=1e-3)
  @test isapprox(Σ[1,1], 1; atol=1e-2)
  @test isapprox(Σ[2,2], 1; atol=1e-2)
  @test isapprox(Σ[3,3], 1; atol=1e-2)
  @test isapprox(Σ[4,4], 1; atol=1e-2)

  tₒ = revert(T, n, c)

  if visualtests
    p₁ = corner(t, title="Original")
    p₂ = corner(n, title="Transformed")
    p₃ = corner(tₒ, title="Reverted")
    p = plot(p₁, p₃, layout=(1,2), size=(1600,800))
    @test_reference joinpath(datadir, "projectionpursuit-1.png") p₂
    @test_reference joinpath(datadir, "projectionpursuit-2.png") p
  end

  a = rand(rng, Arcsine(3), 4000)
  b = rand(rng, BetaPrime(2), 4000)
  t = Table(; a, b)

  T = ProjectionPursuit(rng=MersenneTwister(2))
  n, c = apply(T, t)
  
  μ = mean(Tables.matrix(n), dims=1)
  @test isapprox(μ[1], 0; atol=1e-6)
  @test isapprox(μ[2], 0; atol=1e-6)
  Σ = cov(Tables.matrix(n))
  @test isapprox(Σ[1,1], 1; atol=1e-6)
  @test isapprox(Σ[1,2], 0; atol=1e-6)
  @test isapprox(Σ[2,1], 0; atol=1e-6)
  @test isapprox(Σ[2,2], 1; atol=1e-6)

  tₒ = revert(T, n, c)
  
  if visualtests
    p₁ = corner(t, title="Original")
    p₂ = corner(n, title="Transformed")
    p₃ = corner(tₒ, title="Reverted")
    p = plot(p₁, p₂, p₃, layout=(1,3), size=(1350,500))
    @test_reference joinpath(datadir, "projectionpursuit-3.png") p
  end
end

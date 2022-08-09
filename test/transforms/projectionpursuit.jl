@testset "ProjectionPursuit" begin
  a = rand(100)
  b = rand(100)
  c = b + rand(100)
  t = Table(; a, b, c)

  T = ProjectionPursuit()
  n, c = apply(T, t)

  μ = mean(Tables.matrix(n), dims=1)
  @test isapprox(μ[1], 0; atol=1e-6)
  @test isapprox(μ[2], 0; atol=1e-6)
  @test isapprox(μ[3], 0; atol=1e-6)
  Σ = cov(Tables.matrix(n))
  @test Tables.columnnames(n) == (:a, :b, :c)
  @test isapprox(Σ[1,2], 0; atol=1e-6)
  @test isapprox(Σ[1,3], 0; atol=1e-6)
  @test isapprox(Σ[2,1], 0; atol=1e-6)
  @test isapprox(Σ[2,3], 0; atol=1e-6)
  @test isapprox(Σ[3,1], 0; atol=1e-6)
  @test isapprox(Σ[3,2], 0; atol=1e-6)
  @test isapprox(Σ[1,1], 1; atol=1e-6)
  @test isapprox(Σ[2,2], 1; atol=1e-6)
  @test isapprox(Σ[3,3], 1; atol=1e-6)

  a = rand(rng, Chisq(3), 4000)
  b = rand(rng, Beta(2), 4000)
  t = Table(; a, b)
  T = ProjectionPursuit()
  n, c = apply(T, t)
  tₒ = revert(T, n, c)

  if visualtests
    p₁ = scatter(t.a, t.b, label="Original")
    p₂ = scatter(tₒ.a, tₒ.b, label="Reverted")
    p = plot(p₁, p₂, layout=(1,2))
    @test_reference joinpath(datadir, "projectionpursuit.png") p
  end
end

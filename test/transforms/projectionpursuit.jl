@testset "ProjectionPursuit" begin
  @test TT.parameters(ProjectionPursuit()) == (tol=1.0e-6, deg=5, perc=0.9, n=100)

  rng = StableRNG(42)
  N = 10_000
  a = [2randn(rng, N ÷ 2) .+ 6; randn(rng, N ÷ 2)]
  b = [3randn(rng, N ÷ 2); 2randn(rng, N ÷ 2)]
  c = randn(rng, N)
  d = c .+ 0.6randn(rng, N)
  t = (; a, b, c, d)

  T = ProjectionPursuit(rng=StableRNG(2))
  n, c = apply(T, t)

  @test Tables.columnnames(n) == (:PP1, :PP2, :PP3, :PP4)

  μ = mean(Tables.matrix(n), dims=1)
  Σ = cov(Tables.matrix(n))
  @test all(isapprox.(μ, 0, atol=1e-3))
  @test all(isapprox.(Σ, I(4), atol=1e-2))

  tₒ = revert(T, n, c)

  if visualtests
    fig = Mke.Figure(size=(800, 800))
    pairplot(fig[1, 1], n)
    @test_reference joinpath(datadir, "projectionpursuit-1.png") fig
    fig = Mke.Figure(size=(1600, 800))
    pairplot(fig[1, 1], t)
    pairplot(fig[1, 2], tₒ)
    @test_reference joinpath(datadir, "projectionpursuit-2.png") fig
  end

  a = rand(rng, Arcsine(3), 4000)
  b = rand(rng, BetaPrime(2), 4000)
  t = Table(; a, b)

  T = ProjectionPursuit(rng=StableRNG(2))
  n, c = apply(T, t)

  μ = mean(Tables.matrix(n), dims=1)
  Σ = cov(Tables.matrix(n))
  @test all(isapprox.(μ, 0, atol=1e-8))
  @test all(isapprox.(Σ, I(2), atol=1e-8))

  tₒ = revert(T, n, c)

  if visualtests
    fig = Mke.Figure(size=(1500, 500))
    pairplot(fig[1, 1], t)
    pairplot(fig[1, 2], n)
    pairplot(fig[1, 3], tₒ)
    @test_reference joinpath(datadir, "projectionpursuit-3.png") fig
  end
end

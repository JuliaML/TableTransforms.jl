@testset "ZScore" begin
  x = rand(rng, Normal(7, 10), 4000)
  y = rand(rng, Normal(15, 2), 4000)
  t = Table(; x, y)
  T = ZScore()
  n, c = apply(T, t)
  μ = mean(Tables.matrix(n), dims=1)
  σ = std(Tables.matrix(n), dims=1)
  @test isapprox(μ[1], 0; atol=1e-6)
  @test isapprox(σ[1], 1; atol=1e-6)
  @test isapprox(μ[2], 0; atol=1e-6)
  @test isapprox(σ[2], 1; atol=1e-6)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  # visual tests   
  if visualtests
    p₁ = scatter(t.x, t.y, label="Original", aspectratio=:equal)
    p₂ = scatter(n.x, n.y, label="ZScore", aspectratio=:equal)
    p = plot(p₁, p₂, layout=(1,2))

    @test_reference joinpath(datadir, "zscore.png") p
  end

  # row table
  rt = Tables.rowtable(t)
  T = ZScore()
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  rtₒ = revert(T, n, c)
  @test Tables.matrix(rt) ≈ Tables.matrix(rtₒ)

  # make sure transform works with single-column tables
  t = Table(x=rand(10000))
  n, c = apply(ZScore(), t)
  r = revert(ZScore(), n, c)
  @test isapprox(mean(n.x), 0.0, atol=1e-8)
  @test isapprox(std(n.x), 1.0, atol=1e-8)
  @test isapprox(mean(r.x), mean(t.x), atol=1e-8)
  @test isapprox(std(r.x), std(t.x), atol=1e-8)

  # colspec
  z = x + y
  t = Table(; x, y, z)

  T = ZScore(1, 2)
  n, c = apply(T, t)
  μ = mean(Tables.matrix(n), dims=1)
  σ = std(Tables.matrix(n), dims=1)
  @test isapprox(μ[1], 0; atol=1e-6)
  @test isapprox(σ[1], 1; atol=1e-6)
  @test isapprox(μ[2], 0; atol=1e-6)
  @test isapprox(σ[2], 1; atol=1e-6)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  T = ZScore([:x, :y])
  n, c = apply(T, t)
  μ = mean(Tables.matrix(n), dims=1)
  σ = std(Tables.matrix(n), dims=1)
  @test isapprox(μ[1], 0; atol=1e-6)
  @test isapprox(σ[1], 1; atol=1e-6)
  @test isapprox(μ[2], 0; atol=1e-6)
  @test isapprox(σ[2], 1; atol=1e-6)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  T = ZScore(("x", "y"))
  n, c = apply(T, t)
  μ = mean(Tables.matrix(n), dims=1)
  σ = std(Tables.matrix(n), dims=1)
  @test isapprox(μ[1], 0; atol=1e-6)
  @test isapprox(σ[1], 1; atol=1e-6)
  @test isapprox(μ[2], 0; atol=1e-6)
  @test isapprox(σ[2], 1; atol=1e-6)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  T = ZScore(r"[xy]")
  n, c = apply(T, t)
  μ = mean(Tables.matrix(n), dims=1)
  σ = std(Tables.matrix(n), dims=1)
  @test isapprox(μ[1], 0; atol=1e-6)
  @test isapprox(σ[1], 1; atol=1e-6)
  @test isapprox(μ[2], 0; atol=1e-6)
  @test isapprox(σ[2], 1; atol=1e-6)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)
end

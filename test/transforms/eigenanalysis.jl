@testset "EigenAnalysis" begin
  @test TT.parameters(EigenAnalysis(:V)) == (proj=:V, maxdim=nothing, pratio=1.0)

  # PCA test
  x = rand(rng, Normal(0, 10), 1500)
  y = x + rand(rng, Normal(0, 2), 1500)
  t = Table(; x, y)
  T = EigenAnalysis(:V)
  n, c = apply(T, t)
  Σ = cov(Tables.matrix(n))
  @test Σ[1, 1] > 1
  @test isapprox(Σ[1, 2], 0; atol=1e-6)
  @test isapprox(Σ[2, 1], 0; atol=1e-6)
  @test Σ[2, 2] > 1
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  # DRS test
  x = rand(rng, Normal(0, 10), 1500)
  y = x + rand(rng, Normal(0, 2), 1500)
  t = Table(; x, y)
  T = EigenAnalysis(:VD)
  n, c = apply(T, t)
  Σ = cov(Tables.matrix(n))
  @test isapprox(Σ[1, 2], 0; atol=1e-6)
  @test isapprox(Σ[2, 1], 0; atol=1e-6)
  @test isapprox(Σ[1, 1], 1; atol=1e-6)
  @test isapprox(Σ[2, 2], 1; atol=1e-6)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  # SDS test
  x = rand(rng, Normal(0, 10), 1500)
  y = x + rand(rng, Normal(0, 2), 1500)
  t = Table(; x, y)
  T = EigenAnalysis(:VDV)
  n, c = apply(T, t)
  Σ = cov(Tables.matrix(n))
  @test isapprox(Σ[1, 2], 0; atol=1e-6)
  @test isapprox(Σ[2, 1], 0; atol=1e-6)
  @test isapprox(Σ[1, 1], 1; atol=1e-6)
  @test isapprox(Σ[2, 2], 1; atol=1e-6)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  x = rand(rng, Normal(0, 10), 4000)
  y = x + rand(rng, Normal(0, 2), 4000)
  t₁ = Table(; x, y)
  t₂, c₂ = apply(EigenAnalysis(:V), t₁)
  t₃, c₃ = apply(EigenAnalysis(:VD), t₁)
  t₄, c₄ = apply(EigenAnalysis(:VDV), t₁)
  t₅, c₅ = apply(PCA(), t₁)
  t₆, c₆ = apply(DRS(), t₁)
  t₇, c₇ = apply(SDS(), t₁)

  # visual tests    
  if visualtests
    kwargs = (; bodyaxis=(; aspect=Mke.DataAspect()))
    fig = Mke.Figure(size=(1000, 1000))
    pairplot(fig[1, 1], t₁; kwargs...)
    pairplot(fig[1, 2], t₂; kwargs...)
    pairplot(fig[2, 1], t₃; kwargs...)
    pairplot(fig[2, 2], t₄; kwargs...)
    @test_reference joinpath(datadir, "eigenanalysis-1.png") fig
    fig = Mke.Figure(size=(1500, 1000))
    pairplot(fig[1, 1], t₂; kwargs...)
    pairplot(fig[1, 2], t₃; kwargs...)
    pairplot(fig[1, 3], t₄; kwargs...)
    pairplot(fig[2, 1], t₅; kwargs...)
    pairplot(fig[2, 2], t₆; kwargs...)
    pairplot(fig[2, 3], t₇; kwargs...)
    @test_reference joinpath(datadir, "eigenanalysis-2.png") fig
  end

  # row table
  x = rand(rng, Normal(0, 10), 1500)
  y = x + rand(rng, Normal(0, 2), 1500)
  t = Table(; x, y)
  rt = Tables.rowtable(t)
  T = EigenAnalysis(:V)
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  rtₒ = revert(T, n, c)
  @test Tables.matrix(rt) ≈ Tables.matrix(rtₒ)

  # maxdim
  x = randn(rng, 1000)
  y = x + randn(rng, 1000)
  z = 2x - y + randn(rng, 1000)
  t = Table(; x, y, z)

  # PCA
  T = PCA(maxdim=2)
  n, c = apply(T, t)
  Σ = cov(Tables.matrix(n))
  @test Tables.columnnames(n) == (:PC1, :PC2)
  @test isapprox(Σ[1, 2], 0; atol=1e-6)
  @test isapprox(Σ[2, 1], 0; atol=1e-6)

  # DRS
  T = DRS(maxdim=2)
  n, c = apply(T, t)
  Σ = cov(Tables.matrix(n))
  @test Tables.columnnames(n) == (:PC1, :PC2)
  @test isapprox(Σ[1, 2], 0; atol=1e-6)
  @test isapprox(Σ[2, 1], 0; atol=1e-6)
  @test isapprox(Σ[1, 1], 1; atol=1e-6)
  @test isapprox(Σ[2, 2], 1; atol=1e-6)

  # SDS
  T = SDS(maxdim=2)
  n, c = apply(T, t)
  Σ = cov(Tables.matrix(n))
  @test Tables.columnnames(n) == (:PC1, :PC2)
  @test isapprox(Σ[1, 2], 0; atol=1e-6)
  @test isapprox(Σ[2, 1], 0; atol=1e-6)
  @test isapprox(Σ[1, 1], 1; atol=1e-6)
  @test isapprox(Σ[2, 2], 1; atol=1e-6)

  # pratio
  a = randn(rng, 1000)
  b = randn(rng, 1000)
  c = a + randn(rng, 1000)
  d = b - randn(rng, 1000)
  e = 3d + c - randn(rng, 1000)
  t = Table(; a, b, c, d, e)

  # PCA
  T = PCA(pratio=0.90)
  n, c = apply(T, t)
  Σ = cov(Tables.matrix(n))
  @test Tables.columnnames(n) == (:PC1, :PC2, :PC3)
  @test isapprox(Σ[1, 2], 0; atol=1e-6)
  @test isapprox(Σ[1, 3], 0; atol=1e-6)
  @test isapprox(Σ[2, 1], 0; atol=1e-6)
  @test isapprox(Σ[2, 3], 0; atol=1e-6)
  @test isapprox(Σ[3, 1], 0; atol=1e-6)
  @test isapprox(Σ[3, 2], 0; atol=1e-6)

  # DRS
  T = DRS(pratio=0.90)
  n, c = apply(T, t)
  Σ = cov(Tables.matrix(n))
  @test Tables.columnnames(n) == (:PC1, :PC2, :PC3)
  @test isapprox(Σ[1, 2], 0; atol=1e-6)
  @test isapprox(Σ[1, 3], 0; atol=1e-6)
  @test isapprox(Σ[2, 1], 0; atol=1e-6)
  @test isapprox(Σ[2, 3], 0; atol=1e-6)
  @test isapprox(Σ[3, 1], 0; atol=1e-6)
  @test isapprox(Σ[3, 2], 0; atol=1e-6)
  @test isapprox(Σ[1, 1], 1; atol=1e-6)
  @test isapprox(Σ[2, 2], 1; atol=1e-6)
  @test isapprox(Σ[3, 3], 1; atol=1e-6)

  # SDS
  T = SDS(pratio=0.90)
  n, c = apply(T, t)
  Σ = cov(Tables.matrix(n))
  @test Tables.columnnames(n) == (:PC1, :PC2, :PC3)
  @test isapprox(Σ[1, 2], 0; atol=1e-6)
  @test isapprox(Σ[1, 3], 0; atol=1e-6)
  @test isapprox(Σ[2, 1], 0; atol=1e-6)
  @test isapprox(Σ[2, 3], 0; atol=1e-6)
  @test isapprox(Σ[3, 1], 0; atol=1e-6)
  @test isapprox(Σ[3, 2], 0; atol=1e-6)
  @test isapprox(Σ[1, 1], 1; atol=1e-6)
  @test isapprox(Σ[2, 2], 1; atol=1e-6)
  @test isapprox(Σ[3, 3], 1; atol=1e-6)
end

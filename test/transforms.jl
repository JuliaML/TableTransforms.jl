@testset "Transforms" begin
  @testset "Identity" begin
    # TODO
  end

  @testset "Center" begin
    # TODO
  end

  @testset "Scale" begin
    # TODO
  end

  @testset "ZScore" begin
    # TODO
  end

  @testset "EigenAnalysis" begin
    # PCA test
    x = rand(Normal(0,10), 1500)
    y = x + rand(Normal(0,2), 1500)
    t = DataFrame(:x => x, :y => y)
    n, c = apply(EigenAnalysis(:V), t)
    Σ = cov(Tables.matrix(n))
    @test isapprox(Σ[1,2], 0; atol=1e-6)
    @test isapprox(Σ[2,1], 0; atol=1e-6)
    tₒ = revert(EigenAnalysis(:V), n, c)
    @test t ≈ tₒ

    # DRS test
    x = rand(Normal(0,10), 1500)
    y = x + rand(Normal(0,2), 1500)
    t = DataFrame(:x => x, :y => y)
    n, c = apply(EigenAnalysis(:VD), t)
    Σ = cov(Tables.matrix(n))
    @test isapprox(Σ[1,2], 0; atol=1e-6)
    @test isapprox(Σ[2,1], 0; atol=1e-6)
    @test isapprox(Σ[1,1], 1; atol=1e-6)
    @test isapprox(Σ[2,2], 1; atol=1e-6)
    tₒ = revert(EigenAnalysis(:VD), n, c)
    @test t ≈ tₒ

    # SDS test
    x = rand(Normal(0,10), 1500)
    y = x + rand(Normal(0,2), 1500)
    t = DataFrame(:x => x, :y => y)
    n, c = apply(EigenAnalysis(:VDV), t)
    Σ = cov(Tables.matrix(n))
    @test isapprox(Σ[1,2], 0; atol=1e-6)
    @test isapprox(Σ[2,1], 0; atol=1e-6)
    @test isapprox(Σ[1,1], 1; atol=1e-6)
    @test isapprox(Σ[2,2], 1; atol=1e-6)
    tₒ = revert(EigenAnalysis(:VDV), n, c)
    @test t ≈ tₒ

    # visual tests
    Random.seed!(42) # to reproduce the results
    x = rand(Normal(0,10), 1500)
    y = x + rand(Normal(0,2), 1500)
    t = DataFrame(:x => x, :y => y)
    t₁, c₁ = apply(EigenAnalysis(:V), t)
    t₂, c₂ = apply(EigenAnalysis(:VD), t)
    t₃, c₃ = apply(EigenAnalysis(:VDV), t)
    p₁ = scatter(t₁[:, :x], t₁[:, :y])
    p₂ = scatter(t₂[:, :x], t₂[:, :y])
    p₃ = scatter(t₃[:, :x], t₃[:, :y])
    
    if visualtests
      @test_reference datadir * "/pca.png" plot(p₁, aspect_ratio=:equal, markersize=0.5)
      @test_reference datadir * "/drs.png" plot(p₂, aspect_ratio=:equal, markersize=0.5)
      @test_reference datadir * "/sds.png" plot(p₃, aspect_ratio=:equal, markersize=0.5)
    end
  end

  @testset "Sequential" begin
    # TODO
  end

  @testset "Parallel" begin
    # TODO
  end
end
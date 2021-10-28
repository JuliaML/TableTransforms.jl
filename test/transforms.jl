@testset "Transforms" begin
  @testset "Identity" begin
    x = rand(4000)
    y = rand(4000)
    t = DataFrame(:x => x, :y => y)
    n, c = apply(Identity(), t)
    @test t == n
    tₒ = revert(Identity(), n, c)
    @test t == tₒ
  end

  @testset "Center" begin
    Random.seed!(42) # to reproduce the results
    x = rand(Normal(2,1), 4000)
    y = rand(Normal(5,1), 4000)
    t = DataFrame(:x => x, :y => y)
    n, c = apply(Center(), t)
    μ = mean(Tables.matrix(n), dims=1)
    @test isapprox(μ[1], 0; atol=1e-6)
    @test isapprox(μ[2], 0; atol=1e-6)
    tₒ = revert(Center(), n, c)
    @test t ≈ tₒ

    # visual tests
    pₒ = scatter(t[:, :x], t[:, :y], label="Original")
    p = scatter(n[:, :x], n[:, :y], label="Center")
    
    if visualtests
      @test_reference joinpath(datadir,  "center.png") plot(pₒ, p, layout=(1,2))
    end
  end

  @testset "Scale" begin
    # TODO
  end

  @testset "ZScore" begin
    Random.seed!(42) # to reproduce the results
    x = rand(Normal(7,10), 4000)
    y = rand(Normal(15,2), 4000)
    t = DataFrame(:x => x, :y => y)
    n, c = apply(ZScore(), t)
    μ = mean(Tables.matrix(n), dims=1)
    σ = std(Tables.matrix(n), dims=1)
    @test isapprox(μ[1], 0; atol=1e-6)
    @test isapprox(σ[1], 1; atol=1e-6)
    @test isapprox(μ[2], 0; atol=1e-6)
    @test isapprox(σ[2], 1; atol=1e-6)
    tₒ = revert(ZScore(), n, c)
    @test t ≈ tₒ

    # visual tests
    pₒ = scatter(t[:, :x], t[:, :y], label="Original")
    p = scatter(n[:, :x], n[:, :y], label="ZScore")
    
    if visualtests
      @test_reference joinpath(datadir,"zscore.png") plot(pₒ, p, layout=(1,2))
    end
  end

  @testset "EigenAnalysis" begin
    # PCA test
    x = rand(Normal(0,10), 1500)
    y = x + rand(Normal(0,2), 1500)
    t = DataFrame(:x => x, :y => y)
    n, c = apply(EigenAnalysis(:V), t)
    Σ = cov(Tables.matrix(n))
    @test Σ[1,1] > 1
    @test isapprox(Σ[1,2], 0; atol=1e-6)
    @test isapprox(Σ[2,1], 0; atol=1e-6)
    @test Σ[2,2] > 1
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
    x = rand(Normal(0,10), 4000)
    y = x + rand(Normal(0,2), 4000)
    t = DataFrame(:x => x, :y => y)
    t₁, c₁ = apply(EigenAnalysis(:V), t)
    t₂, c₂ = apply(EigenAnalysis(:VD), t)
    t₃, c₃ = apply(EigenAnalysis(:VDV), t)
    t₄, c₄ = apply(PCA(), t)
    t₅, c₅ = apply(DRS(), t)
    t₆, c₆ = apply(SDS(), t)
    pₒ = scatter(t[:, :x], t[:, :y], label="Original")
    p₁ = scatter(t₁[:, :x], t₁[:, :y], label="V")
    p₂ = scatter(t₂[:, :x], t₂[:, :y], label="VD")
    p₃ = scatter(t₃[:, :x], t₃[:, :y], label="VDV")
    p₄ = scatter(t₄[:, :x], t₄[:, :y], label="PCA")
    p₅ = scatter(t₅[:, :x], t₅[:, :y], label="DRS")
    p₆ = scatter(t₆[:, :x], t₆[:, :y], label="SDS")
    
    if visualtests
      @test_reference joinpath(datadir,  "eigenanalysis-1.png") plot(pₒ, p₁, p₂, p₃, layout=(2,2))
      @test_reference joinpath(datadir,  "eigenanalysis-2.png") plot(p₁, p₂, p₃, p₄, p₅, p₆, layout=(2,3))
    end
  end

  @testset "Sequential" begin
    # TODO
  end

  @testset "Parallel" begin
    # TODO
  end
end
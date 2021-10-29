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
    if visualtests
      p₁ = scatter(t.x, t.y, label="Original")
      p₂ = scatter(n.x, n.y, label="Center")
      p = plot(p₁, p₂, layout=(1,2))

      @test_reference joinpath(datadir,  "center.png") p
    end
  end

  @testset "Scale" begin
    Random.seed!(42) # to reproduce the results
    x = rand(Normal(4,3), 4000)
    y = rand(Normal(7,5), 4000)
    t = DataFrame(:x => x, :y => y)
    n, c = apply(Scale(low=0, high=1), t)
    @test all(x -> x <= 1, n.x)
    @test all(x -> x >= 0, n.x)
    @test all(y -> y <= 1, n.y)
    @test all(y -> y >= 0, n.y)
    tₒ = revert(Scale(low=0, high=1), n, c)
    @test t ≈ tₒ

    # visual tests   
    if visualtests
      p₁ = scatter(t.x, t.y, label="Original")
      p₂ = scatter(n.x, n.y, label="Scale")
      p = plot(p₁, p₂, layout=(1,2))

      @test_reference joinpath(datadir,"scale.png") p
    end
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
    if visualtests
      p₁ = scatter(t.x, t.y, label="Original")
      p₂ = scatter(n.x, n.y, label="ZScore")
      p = plot(p₁, p₂, layout=(1,2))

      @test_reference joinpath(datadir,"zscore.png") p
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

    Random.seed!(42) # to reproduce the results
    x = rand(Normal(0,10), 4000)
    y = x + rand(Normal(0,2), 4000)
    t₁ = DataFrame(:x => x, :y => y)
    t₂, c₂ = apply(EigenAnalysis(:V), t₁)
    t₃, c₃ = apply(EigenAnalysis(:VD), t₁)
    t₄, c₄ = apply(EigenAnalysis(:VDV), t₁)
    t₅, c₅ = apply(PCA(), t₁)
    t₆, c₆ = apply(DRS(), t₁)
    t₇, c₇ = apply(SDS(), t₁)

    # visual tests    
    if visualtests
      p₁ = scatter(t₁.x, t₁.y, label="Original")
      p₂ = scatter(t₂.x, t₂.y, label="V")
      p₃ = scatter(t₃.x, t₃.y, label="VD")
      p₄ = scatter(t₄.x, t₄.y, label="VDV")
      p₅ = scatter(t₅.x, t₅.y, label="PCA")
      p₆ = scatter(t₆.x, t₆.y, label="DRS")
      p₇ = scatter(t₇.x, t₇.y, label="SDS")
      p = plot(p₁, p₂, p₃, p₄, layout=(2,2))
      q = plot(p₂, p₃, p₄, p₅, p₆, p₇, layout=(2,3))

      @test_reference joinpath(datadir,"eigenanalysis-1.png") p
      @test_reference joinpath(datadir,"eigenanalysis-2.png") q
    end
  end

  @testset "Sequential" begin
    # TODO
  end

  @testset "Parallel" begin
    # TODO
  end
end
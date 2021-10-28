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
    # test PCA direct and inverse transformation
    t = (a = rand(1000), b = rand(1000))
    X = Tables.matrix(t)
    μ = mean(X, dims=1)
    Σ = cov(X)
    _, V = eigen(Σ)
    Vᵀ = transpose(V)

    tₙ, c = apply(EigenAnalysis(:V), t)
    Xₙ = Tables.matrix(tₙ)

    tₒ = revert(EigenAnalysis(:V), tₙ, c)
    Xₒ = Tables.matrix(tₒ)
    @test Xₙ ≈ (X .- μ) * V   # test the result matrix manually
    @test first(c) ≈ Vᵀ       # test if the inverse matrix is computed correctly
    @test last(c) ≈ μ         # test if the means is computed correctly
    @test Xₒ ≈ (Xₙ * Vᵀ .+ μ) # test the revert is working fine
    @test X ≈ Xₒ              # test the back-transform is giving X back, the pattern follows for DRS and SDS tests

    # test DRS direct and inverse transformation
    t = (a = rand(1000), b = rand(1000))
    X = Tables.matrix(t)
    μ = mean(X, dims=1)
    Σ = cov(X)
    λ, V = eigen(Σ)
    Λ = Diagonal(sqrt.(λ))
    S = V * inv(Λ)
    Sⁱ = inv(S)

    tₙ, c = apply(EigenAnalysis(:VD), t)
    Xₙ = Tables.matrix(tₙ)

    tₒ = revert(EigenAnalysis(:VD), tₙ, c)
    Xₒ = Tables.matrix(tₒ)
    @test Xₙ ≈ (X .- μ) * S
    @test first(c) ≈ Sⁱ
    @test last(c) ≈ μ
    @test Xₒ ≈ (Xₙ * Sⁱ .+ μ)
    @test X ≈ Xₒ

    # test SDS direct and inverse transformation
    t = (a = rand(1000), b = rand(1000))
    X = Tables.matrix(t)
    μ = mean(X, dims=1)
    Σ = cov(X)
    λ, V = eigen(Σ)
    Λ = Diagonal(sqrt.(λ))
    Vᵀ = transpose(V)
    S = V * inv(Λ) * Vᵀ
    Sⁱ = inv(S)

    tₙ, c = apply(EigenAnalysis(:VDV), t)
    Xₙ = Tables.matrix(tₙ)

    tₒ = revert(EigenAnalysis(:VDV), tₙ, c)
    Xₒ = Tables.matrix(tₒ)
    @test Xₙ ≈ (X .- μ) * S
    @test first(c) ≈ Sⁱ
    @test last(c) ≈ μ
    @test Xₒ ≈ (Xₙ * Sⁱ .+ μ)
    @test X ≈ Xₒ
  end

  @testset "Sequential" begin
    # TODO
  end

  @testset "Parallel" begin
    # TODO
  end
end
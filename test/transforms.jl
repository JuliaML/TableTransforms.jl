@testset "Transforms" begin
  @testset "Select" begin
    a = rand(4000)
    b = rand(4000)
    c = rand(4000)
    d = rand(4000)
    e = rand(4000)
    f = rand(4000)
    t = Table(; a, b, c, d, e, f)

    T = Select(:f, :d)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:f, :d)
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Select(:f, :d, :b)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:f, :d, :b)
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Select(:d, :c, :b)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:d, :c, :b)
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Select(:e, :c, :b, :a)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:e, :c, :b, :a)
    tₒ = revert(T, n, c)
    @test t == tₒ
  end

  @testset "Reject" begin
    a = rand(4000)
    b = rand(4000)
    c = rand(4000)
    d = rand(4000)
    e = rand(4000)
    f = rand(4000)
    t = Table(; a, b, c, d, e, f)

    T = Reject(:f, :d)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:a, :b, :c, :e)
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Reject(:f, :d, :b)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:a, :c, :e)
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Reject(:d, :c, :b)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:a, :e, :f)
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Reject(:e, :c, :b, :a)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:d, :f)
    tₒ = revert(T, n, c)
    @test t == tₒ
  end

  @testset "Identity" begin
    x = rand(4000)
    y = rand(4000)
    t = Table(; x, y)
    T = Identity()
    n, c = apply(T, t)
    @test t == n
    tₒ = revert(T, n, c)
    @test t == tₒ
  end

  @testset "Center" begin
    Random.seed!(42) # to reproduce the results
    x = rand(Normal(2,1), 4000)
    y = rand(Normal(5,1), 4000)
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

      @test_reference joinpath(datadir,  "center.png") p
    end
  end

  @testset "Scale" begin
    Random.seed!(42) # to reproduce the results
    x = rand(Normal(4,3), 4000)
    y = rand(Normal(7,5), 4000)
    t = Table(; x, y)
    T = Scale(low=0, high=1)
    n, c = apply(T, t)
    @test all(x -> x <= 1, n.x)
    @test all(x -> x >= 0, n.x)
    @test all(y -> y <= 1, n.y)
    @test all(y -> y >= 0, n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

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
      p₁ = scatter(t.x, t.y, label="Original")
      p₂ = scatter(n.x, n.y, label="ZScore")
      p = plot(p₁, p₂, layout=(1,2))

      @test_reference joinpath(datadir,"zscore.png") p
    end
  end

  @testset "Quantile" begin
    # TODO
  end

  @testset "Functional" begin
    x = π*rand(1500)
    y = π*rand(1500)
    t = Table(; x, y)
    T = Functional(cos)
    n, c = apply(T, t)
    @test all(x -> -1 <= x <= 1, n.x)
    @test all(y -> -1 <= y <= 1, n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = 2*(rand(1500) .- 0.5)
    y = 2*(rand(1500) .- 0.5)
    t = Table(; x, y)
    T = Functional(acos)
    n, c = apply(T, t)
    @test all(x -> 0 <= x <= π, n.x)
    @test all(y -> 0 <= y <= π, n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = π*(rand(1500) .- 0.5)
    y = π*(rand(1500) .- 0.5)
    t = Table(; x, y)
    T = Functional(sin)
    n, c = apply(T, t)
    @test all(x -> -1 <= x <= 1, n.x)
    @test all(y -> -1 <= y <= 1, n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = 2*(rand(1500) .- 0.5)
    y = 2*(rand(1500) .- 0.5)
    t = Table(; x, y)
    T = Functional(asin)
    n, c = apply(T, t)
    @test all(x -> -π/2 <= x <= π/2, n.x)
    @test all(y -> -π/2 <= y <= π/2, n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = rand(Normal(0,25), 1500)
    y = x + rand(Normal(10,2), 1500)
    t = Table(; x, y)
    T = Functional(exp)
    n, c = apply(T, t)
    @test all(x -> x > 0, n.x)
    @test all(y -> y > 0, n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = rand(Normal(0,25), 1500)
    y = x + rand(Normal(10,2), 1500)
    t = Table(; x, y)
    T = Functional(x -> x)
    n, c = apply(T, t)
    @test t == n
    @test isrevertible(T) == false
  end

  @testset "EigenAnalysis" begin
    # PCA test
    x = rand(Normal(0,10), 1500)
    y = x + rand(Normal(0,2), 1500)
    t = Table(; x, y)
    T = EigenAnalysis(:V)
    n, c = apply(T, t)
    Σ = cov(Tables.matrix(n))
    @test Σ[1,1] > 1
    @test isapprox(Σ[1,2], 0; atol=1e-6)
    @test isapprox(Σ[2,1], 0; atol=1e-6)
    @test Σ[2,2] > 1
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    # DRS test
    x = rand(Normal(0,10), 1500)
    y = x + rand(Normal(0,2), 1500)
    t = Table(; x, y)
    T = EigenAnalysis(:VD)
    n, c = apply(T, t)
    Σ = cov(Tables.matrix(n))
    @test isapprox(Σ[1,2], 0; atol=1e-6)
    @test isapprox(Σ[2,1], 0; atol=1e-6)
    @test isapprox(Σ[1,1], 1; atol=1e-6)
    @test isapprox(Σ[2,2], 1; atol=1e-6)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    # SDS test
    x = rand(Normal(0,10), 1500)
    y = x + rand(Normal(0,2), 1500)
    t = Table(; x, y)
    T = EigenAnalysis(:VDV)
    n, c = apply(T, t)
    Σ = cov(Tables.matrix(n))
    @test isapprox(Σ[1,2], 0; atol=1e-6)
    @test isapprox(Σ[2,1], 0; atol=1e-6)
    @test isapprox(Σ[1,1], 1; atol=1e-6)
    @test isapprox(Σ[2,2], 1; atol=1e-6)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    Random.seed!(42) # to reproduce the results
    x = rand(Normal(0,10), 4000)
    y = x + rand(Normal(0,2), 4000)
    t₁ = Table(; x, y)
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
    x = rand(Normal(0,10), 1500)
    y = x + rand(Normal(0,2), 1500)
    z = y + rand(Normal(0,5), 1500)
    t = Table(; x, y, z)
    T = Scale(low=0.2, high=0.8) → EigenAnalysis(:VDV)
    n, c = apply(T, t)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = rand(Normal(0,10), 1500)
    y = x + rand(Normal(0,2), 1500)
    z = y + rand(Normal(0,5), 1500)
    t = Table(; x, y, z)
    T = Select(:x, :z) → ZScore() → EigenAnalysis(:V) → Scale(low=0, high=1)
    n, c = apply(T, t)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)
  end

  @testset "Parallel" begin
    x = rand(Normal(0,10), 1500)
    y = x + rand(Normal(0,2), 1500)
    z = y + rand(Normal(0,5), 1500)
    t = Table(; x, y, z)
    T = Scale(low=0.3, high=0.6) ⊔ EigenAnalysis(:VDV)
    n, c = apply(T, t)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    # check cardinality of Parallel
    x = rand(Normal(0,10), 1500)
    y = x + rand(Normal(0,2), 1500)
    z = y + rand(Normal(0,5), 1500)
    t = Table(; x, y, z)
    T = ZScore() ⊔ EigenAnalysis(:V)
    n = T(t)
    @test length(Tables.columnnames(n)) == 6

    # distributivity with respect to Sequential
    x = rand(Normal(0,10), 1500)
    y = x + rand(Normal(0,2), 1500)
    z = y + rand(Normal(0,5), 1500)
    t = Table(; x, y, z)
    T₁ = Center()
    T₂ = Scale(low=0.2, high=0.8)
    T₃ = EigenAnalysis(:VD)
    P₁ = T₁ → (T₂ ⊔ T₃)
    P₂ = (T₁ → T₂) ⊔ (T₁ →T₃)
    n₁ = P₁(t)
    n₂ = P₂(t)
    @test Tables.matrix(n₁) ≈ Tables.matrix(n₂)
  end
end
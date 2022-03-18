@testset "Transforms" begin
  # using MersenneTwister for compatibility between Julia versions
  rng = MersenneTwister(42)
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
    @test Tables.columnnames(n) == [:f, :d]
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Select(:f, :d, :b)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:f, :d, :b]
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Select(:d, :c, :b)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:d, :c, :b]
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Select(:e, :c, :b, :a)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:e, :c, :b, :a]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # selection with tuples
    T = Select((:e, :c, :b, :a))
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:e, :c, :b, :a]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # selection with vectors
    T = Select([:e, :c, :b, :a])
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:e, :c, :b, :a]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # selection with strings
    T = Select("d", "c", "b")
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:d, :c, :b]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # selection with tuple of strings
    T = Select(("d", "c", "b"))
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:d, :c, :b]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # selection with vector of strings
    T = Select(["d", "c", "b"])
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:d, :c, :b]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # selection with single column
    @test (Select(:a) == Select("a") ==
           Select((:a,)) == Select(("a",)) ==
           Select([:a]) == Select(["a"]))

    # reapply test
    T = Select(:b, :c, :d)
    n1, c1 = apply(T, t)
    n2 = reapply(T, t, c1)
    @test n1 == n2

    # selection with Regex
    T = Select(r"[dcb]")
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:b, :c, :d] # the order of columns is preserved
    tₒ = revert(T, n, c)
    @test t == tₒ

    x1 = rand(4000)
    x2 = rand(4000)
    y1 = rand(4000)
    y2 = rand(4000)
    t = Table(; x1, x2, y1, y2)

    # select columns whose names contain the character x
    T = Select(r"x")
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:x1, :x2]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # select columns whose names contain the character y
    T = Select(r"y")
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:y1, :y2]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # throws: Select without arguments
    @test_throws ArgumentError Select()
    @test_throws ArgumentError Select(())

    # throws: empty selection
    @test_throws AssertionError apply(Select(r"a"), t)
    @test_throws AssertionError apply(Select(Symbol[]), t)
    @test_throws AssertionError apply(Select(String[]), t)

    # throws: columns that do not exist in the original table
    @test_throws AssertionError apply(Select(:x3, :y3), t)
    @test_throws AssertionError apply(Select([:x3, :y3]), t)
    @test_throws AssertionError apply(Select((:x3, :y3)), t)
    @test_throws AssertionError apply(Select("x3", "y3"), t)
    @test_throws AssertionError apply(Select(["x3", "y3"]), t)
    @test_throws AssertionError apply(Select(("x3", "y3")), t)
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
    @test Tables.columnnames(n) == [:a, :b, :c, :e]
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Reject(:f, :d, :b)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:a, :c, :e]
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Reject(:d, :c, :b)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:a, :e, :f]
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Reject(:e, :c, :b, :a)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:d, :f]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # rejection with tuples
    T = Reject((:e, :c, :b, :a))
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:d, :f]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # rejection with vectors
    T = Reject([:e, :c, :b, :a])
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:d, :f]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # rejection with strings
    T = Reject("d", "c", "b")
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:a, :e, :f]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # rejection with tuple of strings
    T = Reject(("d", "c", "b"))
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:a, :e, :f]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # rejection with vector of strings
    T = Reject(["d", "c", "b"])
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:a, :e, :f]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # rejection with single column
    @test (Reject(:a) == Reject("a") ==
           Reject((:a,)) == Reject(("a",)) ==
           Reject([:a]) == Reject(["a"]))

    # reapply test
    T = Reject(:b, :c, :d)
    n1, c1 = apply(T, t)
    n2 = reapply(T, t, c1)
    @test n1 == n2

    # rejection with Regex
    T = Reject(r"[dcb]")
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:a, :e, :f] # the order of columns is preserved
    tₒ = revert(T, n, c)
    @test t == tₒ

    x1 = rand(4000)
    x2 = rand(4000)
    y1 = rand(4000)
    y2 = rand(4000)
    t = Table(; x1, x2, y1, y2)

    # reject columns whose names contain the character x
    T = Reject(r"x")
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:y1, :y2]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # reject columns whose names contain the character y
    T = Reject(r"y")
    n, c = apply(T, t)
    @test Tables.columnnames(n) == [:x1, :x2]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # throws: Reject without arguments
    @test_throws ArgumentError Reject()
    @test_throws ArgumentError Reject(())

    # throws: reject all columns
    @test_throws AssertionError apply(Reject(r"[xy]"), t)
    @test_throws AssertionError apply(Reject(:x1, :x2, :y1, :y2), t)
    @test_throws AssertionError apply(Reject([:x1, :x2, :y1, :y2]), t)
    @test_throws AssertionError apply(Reject((:x1, :x2, :y1, :y2)), t)
    @test_throws AssertionError apply(Reject("x1", "x2", "y1", "y2"), t)
    @test_throws AssertionError apply(Reject(["x1", "x2", "y1", "y2"]), t)
    @test_throws AssertionError apply(Reject(["x1", "x2", "y1", "y2"]), t)
  end

  @testset "TableSelection" begin
    a = rand(4000)
    b = rand(4000)
    c = rand(4000)
    d = rand(4000)
    e = rand(4000)
    f = rand(4000)
    t = Table(; a, b, c, d, e, f)

    # Tables.jl interface
    s = TableTransforms.TableSelection(t, [:a, :b, :e])
    @test Tables.istable(s) == true
    @test Tables.columnaccess(s) == true
    @test Tables.rowaccess(s) == false
    @test Tables.columns(s) === s
    @test Tables.columnnames(s) == [:a, :b, :e]
    @test Tables.schema(s).names == (:a, :b, :e)
    @test Tables.schema(s).types == (Float64, Float64, Float64)
    @test Tables.materializer(s) == Tables.materializer(t)

    # getcolumn
    cols = Tables.columns(t)
    @test Tables.getcolumn(s, :a) == Tables.getcolumn(cols, :a)
    @test Tables.getcolumn(s, 1) == Tables.getcolumn(cols, 1)
    @test Tables.getcolumn(s, 3) == Tables.getcolumn(cols, :e)

    # throws
    @test_throws AssertionError TableTransforms.TableSelection(t, [:a, :b, :z])
  end

  @testset "Rename" begin
    a = rand(4000)
    b = rand(4000)
    c = rand(4000)
    d = rand(4000)
    t = Table(; a, b, c, d)

    T = Rename(Dict(:a => :x))
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:x, :b, :c, :d)
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Rename(Dict(:a => :x, :c => :y))
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:x, :b, :y, :d)
    tₒ = revert(T, n, c)
    @test t == tₒ

    # rename with string pairs
    T = Rename("a" => "x", "c" => "y")
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:x, :b, :y, :d)
    tₒ = revert(T, n, c)
    @test t == tₒ

    # rename with symbol pairs
    T = Rename(:a => :x, :c => :y)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:x, :b, :y, :d)
    tₒ = revert(T, n, c)
    @test t == tₒ

    # rename with mixed pairs
    T = Rename("a" => :x)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:x, :b, :c, :d)
    tₒ = revert(T, n, c)
    @test t == tₒ
    
    T = Rename("a" => :x, :c => "y")
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:x, :b, :y, :d)
    tₒ = revert(T, n, c)
    @test t == tₒ

    # reapply test
    T = Rename(:b => :x, :d => :y)
    n1, c1 = apply(T, t)
    n2 = reapply(T, t, c1)
    @test n1 == n2
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
    # using rng for reproducible results
    x = rand(rng, Normal(2, 1), 4000)
    y = rand(rng, Normal(5, 1), 4000)
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

      @test_reference joinpath(datadir, "center.png") p
    end
  end

  @testset "Scale" begin
    # constant column
    x = fill(3.0, 10)
    y = rand(10)
    t = Table(; x, y)
    T = MinMax()
    n, c = apply(T, t)
    @test n.x == x
    @test n.y != y
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    # using rng for reproducible results
    x = rand(rng, Normal(4, 3), 4000)
    y = rand(rng, Normal(7, 5), 4000)
    t = Table(; x, y)
    T = Scale(low=0, high=1)
    n, c = apply(T, t)
    @test all(≤(1), n.x)
    @test all(≥(0), n.x)
    @test all(≤(1), n.y)
    @test all(≥(0), n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    # visual tests   
    if visualtests
      p₁ = scatter(t.x, t.y, label="Original")
      p₂ = scatter(n.x, n.y, label="Scale")
      p = plot(p₁, p₂, layout=(1,2))

      @test_reference joinpath(datadir, "scale.png") p
    end
  end

  @testset "ZScore" begin
    # using rng for reproducible results
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
      p₁ = scatter(t.x, t.y, label="Original")
      p₂ = scatter(n.x, n.y, label="ZScore")
      p = plot(p₁, p₂, layout=(1,2))

      @test_reference joinpath(datadir, "zscore.png") p
    end
  end

  @testset "Quantile" begin
    t = (z=rand(1000),)
    n, c = apply(Quantile(), t)
    r = revert(Quantile(), n, c)
    @test all(-4 .< extrema(n.z) .< 4)
    @test all(0 .≤ extrema(r.z) .≤ 1)

    # constant column
    x = fill(3.0, 10)
    y = rand(10)
    t = Table(; x, y)
    T = Quantile()
    n, c = apply(T, t)
    @test maximum(abs, n.x - x) < 0.1
    @test n.y != y
    tₒ = revert(T, n, c)
    @test tₒ.x == t.x
  end

  @testset "Functional" begin
    x = π*rand(1500)
    y = π*rand(1500)
    t = Table(; x, y)
    T = Functional(cos)
    n, c = apply(T, t)
    @test all(x -> -1 ≤ x ≤ 1, n.x)
    @test all(y -> -1 ≤ y ≤ 1, n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = 2*(rand(1500) .- 0.5)
    y = 2*(rand(1500) .- 0.5)
    t = Table(; x, y)
    T = Functional(acos)
    n, c = apply(T, t)
    @test all(x -> 0 ≤ x ≤ π, n.x)
    @test all(y -> 0 ≤ y ≤ π, n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = π*(rand(1500) .- 0.5)
    y = π*(rand(1500) .- 0.5)
    t = Table(; x, y)
    T = Functional(sin)
    n, c = apply(T, t)
    @test all(x -> -1 ≤ x ≤ 1, n.x)
    @test all(y -> -1 ≤ y ≤ 1, n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = 2*(rand(1500) .- 0.5)
    y = 2*(rand(1500) .- 0.5)
    t = Table(; x, y)
    T = Functional(asin)
    n, c = apply(T, t)
    @test all(x -> -π/2 ≤ x ≤ π/2, n.x)
    @test all(y -> -π/2 ≤ y ≤ π/2, n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = rand(Normal(0,25), 1500)
    y = x + rand(Normal(10,2), 1500)
    t = Table(; x, y)
    T = Functional(exp)
    n, c = apply(T, t)
    @test all(>(0), n.x)
    @test all(>(0), n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = rand(Normal(0,25), 1500)
    y = x + rand(Normal(10,2), 1500)
    t = Table(; x, y)
    T = Functional(x -> x)
    n, c = apply(T, t)
    @test t == n
    @test isrevertible(T) == false

    # functor tests
    x = rand(1500)
    y = rand(1500)
    t = Table(; x, y)
    f = Polynomial(1, 2, 3) # f(x) = 1 + 2x + 3x²
    T = Functional(f)
    n, c = apply(T, t)
    @test f.(x) == n.x
    @test f.(y) == n.y
    @test all(≥(1), n.x)
    @test all(≥(1), n.y)
    @test isrevertible(T) == false
  end

  @testset "EigenAnalysis" begin
    # PCA test
    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
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
    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
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
    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
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

    # using rng for reproducible results
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
      p₁ = scatter(t₁.x, t₁.y, label="Original")
      p₂ = scatter(t₂.x, t₂.y, label="V")
      p₃ = scatter(t₃.x, t₃.y, label="VD")
      p₄ = scatter(t₄.x, t₄.y, label="VDV")
      p₅ = scatter(t₅.x, t₅.y, label="PCA")
      p₆ = scatter(t₆.x, t₆.y, label="DRS")
      p₇ = scatter(t₇.x, t₇.y, label="SDS")
      p = plot(p₁, p₂, p₃, p₄, layout=(2,2))
      q = plot(p₂, p₃, p₄, p₅, p₆, p₇, layout=(2,3))

      @test_reference joinpath(datadir, "eigenanalysis-1.png") p
      @test_reference joinpath(datadir, "eigenanalysis-2.png") q
    end
  end

  @testset "Sequential" begin
    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
    z = y + rand(Normal(0, 5), 1500)
    t = Table(; x, y, z)
    T = Scale(low=0.2, high=0.8) → EigenAnalysis(:VDV)
    n, c = apply(T, t)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
    z = y + rand(Normal(0, 5), 1500)
    t = Table(; x, y, z)
    T = Select(:x, :z) → ZScore() → EigenAnalysis(:V) → Scale(low=0, high=1)
    n, c = apply(T, t)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    # reapply with Sequential transform
    t = Table(x=rand(1000))
    T = ZScore() → Quantile()
    n1, c1 = apply(T, t)
    n2 = reapply(T, t, c1)
    @test n1 == n2
  end

  @testset "Parallel" begin
    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
    z = y + rand(Normal(0, 5), 1500)
    t = Table(; x, y, z)
    T = Scale(low=0.3, high=0.6) ⊔ EigenAnalysis(:VDV)
    n, c = apply(T, t)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    # check cardinality of Parallel
    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
    z = y + rand(Normal(0, 5), 1500)
    t = Table(; x, y, z)
    T = ZScore() ⊔ EigenAnalysis(:V)
    n = T(t)
    @test length(Tables.columnnames(n)) == 6

    # distributivity with respect to Sequential
    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
    z = y + rand(Normal(0, 5), 1500)
    t = Table(; x, y, z)
    T₁ = Center()
    T₂ = Scale(low=0.2, high=0.8)
    T₃ = EigenAnalysis(:VD)
    P₁ = T₁ → (T₂ ⊔ T₃)
    P₂ = (T₁ → T₂) ⊔ (T₁ → T₃)
    n₁ = P₁(t)
    n₂ = P₂(t)
    @test Tables.matrix(n₁) ≈ Tables.matrix(n₂)

    # reapply with Parallel transform
    t = Table(x=rand(1000))
    T = ZScore() ⊔ Quantile()
    n1, c1 = apply(T, t)
    n2 = reapply(T, t, c1)
    @test n1 == n2
  end

  @testset "Filter" begin
    # Test with _check_no_missing_in_row
    col1 = [1, 2, 3, 4, 5]
    col2 = [missing, 2, 3, 4, 5]
    col3 = [5, 5, 5, 5, 5]
    col4 = [1, 2, 3, 4, 5]
    col5 = [1, 2, missing, 4, 5]
    table = Table(;col1, col2, col3, col4, col5)

    function _check_no_missing_in_row(row)
      for el in row
          el === missing && return false
      end
  
      return true
    end

    f1 = table |> Filter(_check_no_missing_in_row)
    @test length(f1) == 3

    # Test with more_than_15
    f2 = table |> Filter(row -> sum(skipmissing(row)) > 15)
    @test length(f2) == 2

    # Test revert function
    newtable, cache = apply(Filter(_check_no_missing_in_row), table)
    reverted_table = revert(Filter, newtable, cache)
    @test table == reverted_table
  end

  @testset "Miscellaneous" begin
    # make sure transforms work with
    # single-column tables
    t = Table(x=rand(10000))
    n, c = apply(ZScore(), t)
    r = revert(ZScore(), n, c)
    @test isapprox(mean(n.x), 0.0, atol=1e-8)
    @test isapprox(std(n.x), 1.0, atol=1e-8)
    @test isapprox(mean(r.x), mean(t.x), atol=1e-8)
    @test isapprox(std(r.x), std(t.x), atol=1e-8)
  end
end

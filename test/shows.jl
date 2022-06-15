@testset "Shows" begin
  @testset "Select" begin
    T = Select(:a, :b, :c)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Select((:a, :b, :c))"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Select transform with parameters:
     colspec = (:a, :b, :c)"""
  end

  @testset "Reject" begin
    T = Reject(:a, :b, :c)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Reject((:a, :b, :c))"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Reject transform with parameters:
     colspec = (:a, :b, :c)"""
  end

  @testset "Rename" begin
    pairs = Dict(:a => :x, :c => :y)
    T = Rename(pairs)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Rename($pairs)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Rename transform with parameters:
     names = $pairs"""
  end

  @testset "StdNames" begin
    T = StdNames(:upper)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "StdNames(:upper)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    StdNames transform with parameters:
     spec = :upper"""
  end

  @testset "Sort" begin
    T = Sort([:a, :c], rev=true)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Sort([:a, :c], (rev = true,))"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Sort transform with parameters:
     colspec = [:a, :c]
     kwargs = (rev = true,)"""
  end

  @testset "Sample" begin
    T = Sample(30, replace=false, ordered=true)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Sample(Random._GLOBAL_RNG(), nothing, 30, false, true)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Sample transform with parameters:
     rng = Random._GLOBAL_RNG()
     wv = nothing
     n = 30
     replace = false
     ordered = true"""
  end

  @testset "Filter" begin
    func = row -> row.c ≥ 2 && row.e > 4
    T = Filter(func)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Filter($(typeof(func))())"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Filter transform with parameters:
     func = $(typeof(func))()"""
  end

  @testset "DropMissing" begin
    T = DropMissing(:a, :b, :c)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "DropMissing((:a, :b, :c))"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    DropMissing transform with parameters:
     colspec = (:a, :b, :c)"""
  end

  @testset "Replace" begin
    pairs = IdDict(1 => -1, 5 => -5)
    T = Replace(pairs)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Replace($pairs)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Replace transform with parameters:
     pairs = $pairs"""
  end

  @testset "Coalesce" begin
    T = Coalesce(0)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Coalesce(0)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Coalesce transform with parameters:
     value = 0"""
  end
  
  @testset "Coerce" begin
    T = Coerce(:a => Continuous, :b => Count)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Coerce((:a => Continuous, :b => Count), false, 1)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Coerce transform with parameters:
     pairs = (:a => Continuous, :b => Count)
     tight = false
     verbosity = 1"""
  end

  @testset "Levels" begin
    T = Levels(:a => ["n", "y"], :b => 1:3, ordered=r"[ab]")

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Levels((:a, :b), r\"[ab]\", ([\"n\", \"y\"], 1:3))"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Levels transform with parameters:
     colspec = (:a, :b)
     ordered = r"[ab]"
     levels = (["n", "y"], 1:3)"""
  end

  @testset "OneHot" begin
    T = OneHot(:a)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "OneHot([:a])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    OneHot transform with parameters:
     colspec = [:a]"""
  end

  @testset "Identity" begin
    T = Identity()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Identity()"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == "Identity transform with parameters:"
  end

  @testset "Center" begin
    T = Center()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Center()"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == "Center transform with parameters:"
  end

  @testset "Scale" begin
    T = Scale()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Scale(0.25, 0.75)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Scale transform with parameters:
     low = 0.25
     high = 0.75"""
  end

  @testset "ZScore" begin
    T = ZScore()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "ZScore()"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == "ZScore transform with parameters:"
  end

  @testset "Quantile" begin
    T = Quantile()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Quantile(Normal{Float64}(μ=0.0, σ=1.0))"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Quantile transform with parameters:
     dist = Normal{Float64}(μ=0.0, σ=1.0)"""
  end

  @testset "Functional" begin
    T = Functional(sin)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Functional(sin)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Functional transform with parameters:
     func = sin"""
  end

  @testset "EigenAnalysis" begin
    T = EigenAnalysis(:VDV)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "EigenAnalysis(:VDV, nothing, 1.0)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    EigenAnalysis transform with parameters:
     proj = :VDV
     maxdim = nothing
     pratio = 1.0"""
  end

  @testset "RowTable" begin
    T = RowTable()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "RowTable()"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == "RowTable transform with parameters:"
  end

  @testset "ColTable" begin
    T = ColTable()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "ColTable()"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == "ColTable transform with parameters:"
  end

  @testset "Sequential" begin
    t1 = Select(:x, :z)
    t2 = ZScore()
    t3 = Scale(low=0, high=1)
    pipeline = t1 → t2 → t3

    # compact mode
    iostr = sprint(show, pipeline)
    @test iostr == "Select((:x, :z)) → ZScore() → Scale(0, 1)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), pipeline)
    @test iostr == """
    Sequential
    ├─ Select((:x, :z))
    ├─ ZScore()
    └─ Scale(0, 1)"""
  end

  @testset "Parallel" begin
    t1 = Scale(low=0.3, high=0.6)
    t2 = EigenAnalysis(:VDV)
    t3 = Functional(cos)
    pipeline = t1 ⊔ t2 ⊔ t3

    # compact mode
    iostr = sprint(show, pipeline)
    @test iostr == "Scale(0.3, 0.6) ⊔ EigenAnalysis(:VDV, nothing, 1.0) ⊔ Functional(cos)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), pipeline)
    @test iostr == """
    Parallel
    ├─ Scale(0.3, 0.6)
    ├─ EigenAnalysis(:VDV, nothing, 1.0)
    └─ Functional(cos)"""

    # Parallel with Sequential
    f1 = ZScore()
    f2 = Scale()
    f3 = Functional(cos)
    f4 = Interquartile()
    pipeline = (f1 → f2) ⊔ (f3 → f4)

    # compact mode
    iostr = sprint(show, pipeline)
    @test iostr == "ZScore() → Scale(0.25, 0.75) ⊔ Functional(cos) → Scale(0.25, 0.75)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), pipeline)
    @test iostr == """
    Parallel
    ├─ Sequential
    │  ├─ ZScore()
    │  └─ Scale(0.25, 0.75)
    └─ Sequential
       ├─ Functional(cos)
       └─ Scale(0.25, 0.75)"""
  end
end

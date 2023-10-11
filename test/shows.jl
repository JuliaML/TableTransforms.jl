@testset "Shows" begin
  @testset "Select" begin
    T = Select(:a, :b, :c)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Select([:a, :b, :c], nothing)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Select transform
    ├─ selector = [:a, :b, :c]
    └─ newnames = nothing"""

    # selection with renaming
    T = Select(:a => :x, :b => :y)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Select([:a, :b], [:x, :y])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Select transform
    ├─ selector = [:a, :b]
    └─ newnames = [:x, :y]"""
  end

  @testset "Reject" begin
    T = Reject(:a, :b, :c)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Reject([:a, :b, :c])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Reject transform
    └─ selector = [:a, :b, :c]"""
  end

  @testset "Rename" begin
    T = Rename(:a => :x, :c => :y)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Rename([:a, :c], [:x, :y])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Rename transform
    ├─ selector = [:a, :c]
    └─ newnames = [:x, :y]"""
  end

  @testset "StdNames" begin
    T = StdNames(:upperflat)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "StdNames(:upperflat)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    StdNames transform
    └─ spec = :upperflat"""
  end

  @testset "Sort" begin
    T = Sort([:a, :c], rev=true)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Sort([:a, :c], (rev = true,))"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Sort transform
    ├─ selector = [:a, :c]
    └─ kwargs = (rev = true,)"""
  end

  @testset "Sample" begin
    T = Sample(30, replace=false, ordered=true)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Sample(30, nothing, false, true, Random._GLOBAL_RNG())"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Sample transform
    ├─ size = 30
    ├─ weights = nothing
    ├─ replace = false
    ├─ ordered = true
    └─ rng = Random._GLOBAL_RNG()"""
  end

  @testset "Filter" begin
    pred = row -> row.c ≥ 2 && row.e > 4
    T = Filter(pred)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Filter($(typeof(pred))())"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Filter transform
    └─ pred = $(typeof(pred))()"""
  end

  @testset "DropMissing" begin
    T = DropMissing(:a, :b, :c)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "DropMissing([:a, :b, :c])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    DropMissing transform
    └─ selector = [:a, :b, :c]"""
  end

  @testset "DropExtrema" begin
    T = DropExtrema("a", low=0.25, high=0.75)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "DropExtrema(:a, 0.25, 0.75)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    DropExtrema transform
    ├─ selector = :a
    ├─ low = 0.25
    └─ high = 0.75"""
  end

  @testset "Map" begin
    fun = (a, b) -> 2a + b
    T = Map(:a => sin, [:a, :b] => fun => :c)

    # compact mode
    iostr = sprint(show, T)
    @test iostr ==
          "Map(ColumnSelectors.ColumnSelector[:a, [:a, :b]], Function[sin, $(typeof(fun))()], Union{Nothing, Symbol}[nothing, :c])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Map transform
    ├─ selectors = ColumnSelectors.ColumnSelector[:a, [:a, :b]]
    ├─ funs = Function[sin, $(typeof(fun))()]
    └─ targets = Union{Nothing, Symbol}[nothing, :c]"""
  end

  @testset "Replace" begin
    T = Replace(1 => -1, 5 => -5)

    # compact mode
    iostr = sprint(show, T)
    @test iostr ==
          "Replace(ColumnSelectors.ColumnSelector[all, all], Function[Base.Fix2{typeof(===), Int64}(===, 1), Base.Fix2{typeof(===), Int64}(===, 5)], Any[-1, -5])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Replace transform
    ├─ selectors = ColumnSelectors.ColumnSelector[all, all]
    ├─ preds = Function[Base.Fix2{typeof(===), Int64}(===, 1), Base.Fix2{typeof(===), Int64}(===, 5)]
    └─ news = Any[-1, -5]"""
  end

  @testset "Coalesce" begin
    T = Coalesce(value=0)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Coalesce(all, 0)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Coalesce transform
    ├─ selector = all
    └─ value = 0"""
  end

  @testset "Coerce" begin
    T = Coerce(:a => SciTypes.Continuous, :b => SciTypes.Categorical)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Coerce([:a, :b], DataType[SciTypes.Continuous, SciTypes.Categorical])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Coerce transform
    ├─ selector = [:a, :b]
    └─ scitypes = DataType[SciTypes.Continuous, SciTypes.Categorical]"""
  end

  @testset "Levels" begin
    T = Levels(:a => ["n", "y"], :b => 1:3, ordered=r"[ab]")

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Levels([:a, :b], r\"[ab]\", ([\"n\", \"y\"], 1:3))"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Levels transform
    ├─ selector = [:a, :b]
    ├─ ordered = r"[ab]"
    └─ levels = (["n", "y"], 1:3)"""
  end

  @testset "OneHot" begin
    T = OneHot(:a)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "OneHot(:a, false)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    OneHot transform
    ├─ selector = :a
    └─ categ = false"""
  end

  @testset "Identity" begin
    T = Identity()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Identity()"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == "Identity transform"
  end

  @testset "Center" begin
    T = Center()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Center(all)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Center transform
    └─ selector = all"""
  end

  @testset "Scale" begin
    T = Scale()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Scale(all, 0.25, 0.75)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Scale transform
    ├─ selector = all
    ├─ low = 0.25
    └─ high = 0.75"""
  end

  @testset "ZScore" begin
    T = ZScore()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "ZScore(all)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    ZScore transform
    └─ selector = all"""
  end

  @testset "Quantile" begin
    T = Quantile()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Quantile(all, Normal{Float64}(μ=0.0, σ=1.0))"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Quantile transform
    ├─ selector = all
    └─ dist = Normal{Float64}(μ=0.0, σ=1.0)"""
  end

  @testset "Functional" begin
    T = Functional(sin)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Functional(all, sin)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Functional transform
    ├─ selector = all
    └─ func = sin"""
  end

  @testset "EigenAnalysis" begin
    T = EigenAnalysis(:VDV)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "EigenAnalysis(:VDV, nothing, 1.0)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    EigenAnalysis transform
    ├─ proj = :VDV
    ├─ maxdim = nothing
    └─ pratio = 1.0"""
  end

  @testset "RowTable" begin
    T = RowTable()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "RowTable()"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == "RowTable transform"
  end

  @testset "ColTable" begin
    T = ColTable()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "ColTable()"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == "ColTable transform"
  end

  @testset "SequentialTransform" begin
    t1 = Select(:x, :z)
    t2 = ZScore()
    t3 = Scale(low=0, high=1)
    pipeline = t1 → t2 → t3

    # compact mode
    iostr = sprint(show, pipeline)
    @test iostr == "Select([:x, :z], nothing) → ZScore(all) → Scale(all, 0, 1)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), pipeline)
    @test iostr == """
    SequentialTransform
    ├─ Select([:x, :z], nothing)
    ├─ ZScore(all)
    └─ Scale(all, 0, 1)"""
  end

  @testset "ParallelTableTransform" begin
    t1 = Scale(low=0.3, high=0.6)
    t2 = EigenAnalysis(:VDV)
    t3 = Functional(cos)
    pipeline = t1 ⊔ t2 ⊔ t3

    # compact mode
    iostr = sprint(show, pipeline)
    @test iostr == "Scale(all, 0.3, 0.6) ⊔ EigenAnalysis(:VDV, nothing, 1.0) ⊔ Functional(all, cos)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), pipeline)
    @test iostr == """
    ParallelTableTransform
    ├─ Scale(all, 0.3, 0.6)
    ├─ EigenAnalysis(:VDV, nothing, 1.0)
    └─ Functional(all, cos)"""

    # parallel and sequential
    f1 = ZScore()
    f2 = Scale()
    f3 = Functional(cos)
    f4 = Interquartile()
    pipeline = (f1 → f2) ⊔ (f3 → f4)

    # compact mode
    iostr = sprint(show, pipeline)
    @test iostr == "ZScore(all) → Scale(all, 0.25, 0.75) ⊔ Functional(all, cos) → Scale(all, 0.25, 0.75)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), pipeline)
    @test iostr == """
    ParallelTableTransform
    ├─ SequentialTransform
    │  ├─ ZScore(all)
    │  └─ Scale(all, 0.25, 0.75)
    └─ SequentialTransform
       ├─ Functional(all, cos)
       └─ Scale(all, 0.25, 0.75)"""
  end
end

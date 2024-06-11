@testset "Shows" begin
  @testset "Assert" begin
    T = Assert(:a, :b, :c, cond=allunique)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Assert(selector: [:a, :b, :c], cond: allunique, msg: \"\")"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Assert transform
    ├─ selector: [:a, :b, :c]
    ├─ cond: allunique
    └─ msg: \"\""""
  end

  @testset "Select" begin
    T = Select(:a, :b, :c)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Select(selector: [:a, :b, :c], newnames: nothing)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Select transform
    ├─ selector: [:a, :b, :c]
    └─ newnames: nothing"""

    # selection with renaming
    T = Select(:a => :x, :b => :y)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Select(selector: [:a, :b], newnames: [:x, :y])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Select transform
    ├─ selector: [:a, :b]
    └─ newnames: [:x, :y]"""
  end

  @testset "Reject" begin
    T = Reject(:a, :b, :c)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Reject(selector: [:a, :b, :c])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Reject transform
    └─ selector: [:a, :b, :c]"""
  end

  @testset "Satisfies" begin
    T = Satisfies(allunique)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Satisfies(pred: allunique)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Satisfies transform
    └─ pred: allunique"""
  end

  @testset "Rename" begin
    T = Rename(:a => :x, :c => :y)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Rename(selector: [:a, :c], newnames: [:x, :y])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Rename transform
    ├─ selector: [:a, :c]
    └─ newnames: [:x, :y]"""
  end

  @testset "StdNames" begin
    T = StdNames(:upperflat)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "StdNames(spec: :upperflat)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    StdNames transform
    └─ spec: :upperflat"""
  end

  @testset "StdFeats" begin
    T = StdFeats()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "StdFeats()"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == "StdFeats transform"
  end

  @testset "Sort" begin
    T = Sort([:a, :c], rev=true)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Sort(selector: [:a, :c], kwargs: (rev = true,))"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Sort transform
    ├─ selector: [:a, :c]
    └─ kwargs: (rev = true,)"""
  end

  @testset "Sample" begin
    T = Sample(30, replace=false, ordered=true)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Sample(size: 30, weights: nothing, replace: false, ordered: true, rng: TaskLocalRNG())"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Sample transform
    ├─ size: 30
    ├─ weights: nothing
    ├─ replace: false
    ├─ ordered: true
    └─ rng: TaskLocalRNG()"""
  end

  @testset "Filter" begin
    pred = row -> row.c ≥ 2 && row.e > 4
    T = Filter(pred)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Filter(pred: $(nameof(pred)))"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Filter transform
    └─ pred: $(typeof(pred))()"""
  end

  @testset "DropMissing" begin
    T = DropMissing(:a, :b, :c)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "DropMissing(selector: [:a, :b, :c])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    DropMissing transform
    └─ selector: [:a, :b, :c]"""
  end

  @testset "DropNaN" begin
    T = DropNaN(:a, :b, :c)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "DropNaN(selector: [:a, :b, :c])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    DropNaN transform
    └─ selector: [:a, :b, :c]"""
  end

  @testset "DropExtrema" begin
    T = DropExtrema("a", low=0.25, high=0.75)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "DropExtrema(selector: [:a], low: 0.25, high: 0.75)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    DropExtrema transform
    ├─ selector: [:a]
    ├─ low: 0.25
    └─ high: 0.75"""
  end

  @testset "DropUnits" begin
    T = DropUnits(:a, :b, :c)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "DropUnits(selector: [:a, :b, :c])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    DropUnits transform
    └─ selector: [:a, :b, :c]"""
  end

  @testset "DropConstant" begin
    T = DropConstant()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "DropConstant()"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == "DropConstant transform"
  end

  @testset "AbsoluteUnits" begin
    T = AbsoluteUnits(:a, :b, :c)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "AbsoluteUnits(selector: [:a, :b, :c])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    AbsoluteUnits transform
    └─ selector: [:a, :b, :c]"""
  end

  @testset "Unitify" begin
    T = Unitify()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Unitify()"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == "Unitify transform"
  end

  @testset "Map" begin
    fun = (a, b) -> 2a + b
    T = Map(:a => sin, [:a, :b] => fun => :c)

    # compact mode
    iostr = sprint(show, T)
    @test iostr ==
          "Map(selectors: ColumnSelector[:a, [:a, :b]], funs: Function[sin, $(nameof(fun))], targets: Union{Nothing, Symbol}[nothing, :c])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Map transform
    ├─ selectors: ColumnSelectors.ColumnSelector[:a, [:a, :b]]
    ├─ funs: Function[sin, $(typeof(fun))()]
    └─ targets: Union{Nothing, Symbol}[nothing, :c]"""
  end

  @testset "Replace" begin
    T = Replace(1 => -1, 5 => -5)

    # compact mode
    iostr = sprint(show, T)
    @test iostr ==
          "Replace(selectors: ColumnSelector[all, all], preds: Function[Fix2{typeof(===), Int64}(===, 1), Fix2{typeof(===), Int64}(===, 5)], news: Any[-1, -5])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Replace transform
    ├─ selectors: ColumnSelectors.ColumnSelector[all, all]
    ├─ preds: Function[Base.Fix2{typeof(===), Int64}(===, 1), Base.Fix2{typeof(===), Int64}(===, 5)]
    └─ news: Any[-1, -5]"""
  end

  @testset "Coalesce" begin
    T = Coalesce(value=0)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Coalesce(selector: all, value: 0)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Coalesce transform
    ├─ selector: all
    └─ value: 0"""
  end

  @testset "Coerce" begin
    T = Coerce(:a => DST.Continuous, :b => DST.Categorical)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Coerce(selector: [:a, :b], scitypes: DataType[Continuous, Categorical])"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Coerce transform
    ├─ selector: [:a, :b]
    └─ scitypes: DataType[DataScienceTraits.Continuous, DataScienceTraits.Categorical]"""
  end

  @testset "Levels" begin
    T = Levels(:a => ["n", "y"], :b => 1:3, ordered=r"[ab]")

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Levels(selector: [:a, :b], ordered: r\"[ab]\", levels: ([\"n\", \"y\"], 1:3))"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Levels transform
    ├─ selector: [:a, :b]
    ├─ ordered: r"[ab]"
    └─ levels: (["n", "y"], 1:3)"""
  end

  @testset "OneHot" begin
    T = OneHot(:a)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "OneHot(selector: :a, categ: false)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    OneHot transform
    ├─ selector: :a
    └─ categ: false"""
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
    @test iostr == "Center(selector: all)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Center transform
    └─ selector: all"""
  end

  @testset "LowHigh" begin
    T = LowHigh()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "LowHigh(selector: all, low: 0.25, high: 0.75)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    LowHigh transform
    ├─ selector: all
    ├─ low: 0.25
    └─ high: 0.75"""
  end

  @testset "ZScore" begin
    T = ZScore()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "ZScore(selector: all)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    ZScore transform
    └─ selector: all"""
  end

  @testset "Quantile" begin
    T = Quantile()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Quantile(selector: all, dist: Normal{Float64}(μ=0.0, σ=1.0))"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Quantile transform
    ├─ selector: all
    └─ dist: Normal{Float64}(μ=0.0, σ=1.0)"""
  end

  @testset "Functional" begin
    T = Functional(log)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Functional(selector: all, fun: log)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Functional transform
    ├─ selector: all
    └─ fun: log"""
  end

  @testset "EigenAnalysis" begin
    T = EigenAnalysis(:VDV)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "EigenAnalysis(proj: :VDV, maxdim: nothing, pratio: 1.0)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    EigenAnalysis transform
    ├─ proj: :VDV
    ├─ maxdim: nothing
    └─ pratio: 1.0"""
  end

  @testset "Closure" begin
    T = Closure()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Closure()"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == "Closure transform"
  end

  @testset "Remainder" begin
    T = Remainder()

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Remainder(total: nothing)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Remainder transform
    └─ total: nothing"""
  end

  @testset "Compose" begin
    T = Compose(:a, :b, :c)

    # compact mode
    iostr = sprint(show, T)
    @test iostr == "Compose(selector: [:a, :b, :c], as: :CODA)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), T)
    @test iostr == """
    Compose transform
    ├─ selector: [:a, :b, :c]
    └─ as: :CODA"""
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
    t3 = LowHigh(low=0, high=1)
    pipeline = t1 → t2 → t3

    # compact mode
    iostr = sprint(show, pipeline)
    @test iostr == "Select(selector: [:x, :z], newnames: nothing) → ZScore(selector: all) → LowHigh(selector: all, low: 0, high: 1)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), pipeline)
    @test iostr == """
    SequentialTransform
    ├─ Select(selector: [:x, :z], newnames: nothing)
    ├─ ZScore(selector: all)
    └─ LowHigh(selector: all, low: 0, high: 1)"""
  end

  @testset "ParallelTableTransform" begin
    t1 = LowHigh(low=0.3, high=0.6)
    t2 = EigenAnalysis(:VDV)
    t3 = Functional(exp)
    pipeline = t1 ⊔ t2 ⊔ t3

    # compact mode
    iostr = sprint(show, pipeline)
    @test iostr == "LowHigh(selector: all, low: 0.3, high: 0.6) ⊔ EigenAnalysis(proj: :VDV, maxdim: nothing, pratio: 1.0) ⊔ Functional(selector: all, fun: exp)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), pipeline)
    @test iostr == """
    ParallelTableTransform
    ├─ LowHigh(selector: all, low: 0.3, high: 0.6)
    ├─ EigenAnalysis(proj: :VDV, maxdim: nothing, pratio: 1.0)
    └─ Functional(selector: all, fun: exp)"""

    # parallel and sequential
    f1 = ZScore()
    f2 = LowHigh()
    f3 = Functional(exp)
    f4 = Interquartile()
    pipeline = (f1 → f2) ⊔ (f3 → f4)

    # compact mode
    iostr = sprint(show, pipeline)
    @test iostr == "ZScore(selector: all) → LowHigh(selector: all, low: 0.25, high: 0.75) ⊔ Functional(selector: all, fun: exp) → LowHigh(selector: all, low: 0.25, high: 0.75)"

    # full mode
    iostr = sprint(show, MIME("text/plain"), pipeline)
    @test iostr == """
    ParallelTableTransform
    ├─ SequentialTransform
    │  ├─ ZScore(selector: all)
    │  └─ LowHigh(selector: all, low: 0.25, high: 0.75)
    └─ SequentialTransform
       ├─ Functional(selector: all, fun: exp)
       └─ LowHigh(selector: all, low: 0.25, high: 0.75)"""
  end
end

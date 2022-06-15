@testset "Shows" begin
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

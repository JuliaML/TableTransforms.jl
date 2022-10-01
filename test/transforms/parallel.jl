@testset "Parallel" begin
  x = rand(Normal(0, 10), 1500)
  y = x + rand(Normal(0, 2), 1500)
  z = y + rand(Normal(0, 5), 1500)
  t = Table(; x, y, z)

  T = Scale(low=0.3, high=0.6) ⊔ EigenAnalysis(:VDV)
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  # check cardinality of parallel transform
  T = ZScore() ⊔ EigenAnalysis(:V)
  n = T(t)
  @test length(Tables.columnnames(n)) == 6

  # distributivity with respect to sequential transform
  T₁ = Center()
  T₂ = Scale(low=0.2, high=0.8)
  T₃ = EigenAnalysis(:VD)
  P₁ = T₁ → (T₂ ⊔ T₃)
  P₂ = (T₁ → T₂) ⊔ (T₁ → T₃)
  n₁ = P₁(t)
  n₂ = P₂(t)
  @test Tables.matrix(n₁) ≈ Tables.matrix(n₂)

  # row table
  rt = Tables.rowtable(t)
  T = Scale(low=0.3, high=0.6) ⊔ EigenAnalysis(:VDV)
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  rtₒ = revert(T, n, c)
  @test Tables.matrix(rt) ≈ Tables.matrix(rtₒ)

  # reapply with parallel transform
  t = Table(x=rand(100))
  T = ZScore() ⊔ Quantile()
  n1, c1 = apply(T, t)
  n2 = reapply(T, t, c1)
  @test n1 == n2

  # https://github.com/JuliaML/TableTransforms.jl/issues/80
  t = (a=rand(3), b=rand(3))
  T = Select(:a) ⊔ Select(:b)
  n, c = apply(T, t)
  @test t == n
  tₒ = revert(T, n, c)
  @test tₒ == t
end

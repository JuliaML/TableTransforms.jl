@testset "Sequential" begin
  x = rand(Normal(0, 10), 1500)
  y = x + rand(Normal(0, 2), 1500)
  z = y + rand(Normal(0, 5), 1500)
  t = Table(; x, y, z)

  T = Scale(low=0.2, high=0.8) → EigenAnalysis(:VDV)
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

  # reapply with Sequential transform
  t = Table(x=rand(100))
  T = ZScore() → Quantile()
  n1, c1 = apply(T, t)
  n2 = reapply(T, t, c1)
  @test n1 == n2

  # row table
  rt = Tables.rowtable(t)
  T = Scale(low=0.2, high=0.8) → EigenAnalysis(:VDV)
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  rtₒ = revert(T, n, c)
  @test Tables.matrix(rt) ≈ Tables.matrix(rtₒ)
end

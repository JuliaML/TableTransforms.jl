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

  # row table
  rt = Tables.rowtable(t)
  T = Quantile()
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  rtₒ = revert(T, n, c)
  for (row, rowₒ) in zip(rt, rtₒ)
    @test row.x == rowₒ.x
  end
end

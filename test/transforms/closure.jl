@testset "Closure" begin
  @test isrevertible(Closure())

  a = [2.0, 66.0, 0.0]
  b = [4.0, 22.0, 2.0]
  c = [4.0, 12.0, 98.0]
  t = Table(; a, b, c)

  T = Closure()
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  @test Tables.matrix(n) ≈ [0.2 0.4 0.4; 0.66 0.22 0.12; 0.00 0.02 0.98]
  @test Tables.matrix(tₒ) ≈ Tables.matrix(t)
end

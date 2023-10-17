@testset "Remainder" begin
  @test isrevertible(Remainder())

  a = [2.0, 66.0, 0.0]
  b = [4.0, 22.0, 2.0]
  c = [4.0, 12.0, 98.0]
  t = Table(; a, b, c)
  T = Remainder()
  n, c = apply(T, t)
  total = first(first(c))
  tₒ = revert(T, n, c)
  Xt = Tables.matrix(t)
  Xn = Tables.matrix(n)
  @test Xn[:, 1:(end - 1)] == Xt
  @test all(x -> 0 ≤ x ≤ total, Xn[:, end])
  @test Tables.schema(n).names == (:a, :b, :c, :remainder)
  @test Tables.schema(tₒ).names == (:a, :b, :c)

  t = Table(a=[1.0, 10.0, 0.0], b=[1.0, 5.0, 0.0], c=[4.0, 2.0, 1.0])
  n = reapply(T, t, c)
  Xn = Tables.matrix(n)
  @test all(x -> 0 ≤ x ≤ total, Xn[:, end])

  t = Table(a=[1.0, 10.0, 0.0], b=[1.0, 5.0, 0.0], remainder=[4.0, 2.0, 1.0])
  n = t |> Remainder(18.3)
  @test Tables.schema(n).names == (:a, :b, :remainder, :remainder_)

  n1, c1 = apply(Remainder(), t)
  n2 = reapply(Remainder(), t, c1)
  @test n1 == n2

  @test_throws AssertionError apply(Remainder(8.3), t)
end

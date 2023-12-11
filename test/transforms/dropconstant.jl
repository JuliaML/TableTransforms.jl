@testset "DropConstant" begin
  @test isrevertible(DropUnits())

  a = [4, 6, 7, 8, 1, 2]
  b = fill(5, 6)
  c = [1.9, 7.4, 8.6, 8.9, 2.4, 7.7]
  d = fill(5.5, 6)
  t = Table(; a, b, c, d)

  T = DropConstant()
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :c)
  @test Tables.getcolumn(n, :a) == t.a
  @test Tables.getcolumn(n, :c) == t.c
  tₒ = revert(T, n, c)
  @test t == tₒ

  # revert with different number of rows
  T = DropConstant()
  _, c = apply(T, t)
  n = Table(; a=[t.a; [3, 4, 7, 2]], c=[t.c; [5.3, 4.9, 3.1, 6.8]])
  r = revert(T, n, c)
  @test r.a == n.a
  @test r.b == fill(5, 10)
  @test r.c == n.c
  @test r.d == fill(5.5, 10)
end

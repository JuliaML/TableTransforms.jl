@testset "Filter" begin
  a = [3, 2, 1, 4, 5, 3]
  b = [2, 4, 4, 5, 8, 5]
  c = [1, 1, 6, 2, 4, 1]
  d = [4, 3, 7, 5, 4, 1]
  e = [5, 5, 2, 6, 5, 2]
  f = [4, 4, 3, 4, 5, 2]
  t = Table(; a, b, c, d, e, f)

  T = Filter(row -> all(≤(5), row))
  n, c = apply(T, t)
  @test n.a == [3, 2, 3]
  @test n.b == [2, 4, 5]
  @test n.c == [1, 1, 1]
  @test n.d == [4, 3, 1]
  @test n.e == [5, 5, 2]
  @test n.f == [4, 4, 2]

  # revert test
  @test isrevertible(T)
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Filter(row -> any(>(5), row))
  n, c = apply(T, t)
  @test n.a == [1, 4, 5]
  @test n.b == [4, 5, 8]
  @test n.c == [6, 2, 4]
  @test n.d == [7, 5, 4]
  @test n.e == [2, 6, 5]
  @test n.f == [3, 4, 5]
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Filter(row -> row.a ≥ 3)
  n, c = apply(T, t)
  @test n.a == [3, 4, 5, 3]
  @test n.b == [2, 5, 8, 5]
  @test n.c == [1, 2, 4, 1]
  @test n.d == [4, 5, 4, 1]
  @test n.e == [5, 6, 5, 2]
  @test n.f == [4, 4, 5, 2]
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Filter(row -> row.c ≥ 2 && row.e > 4)
  n, c = apply(T, t)
  @test n.a == [4, 5]
  @test n.b == [5, 8]
  @test n.c == [2, 4]
  @test n.d == [5, 4]
  @test n.e == [6, 5]
  @test n.f == [4, 5]
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Filter(row -> row.b == 4 || row.f == 4)
  n, c = apply(T, t)
  @test n.a == [3, 2, 1, 4]
  @test n.b == [2, 4, 4, 5]
  @test n.c == [1, 1, 6, 2]
  @test n.d == [4, 3, 7, 5]
  @test n.e == [5, 5, 2, 6]
  @test n.f == [4, 4, 3, 4]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # column access
  T = Filter(row -> row."b" == 4 || row."f" == 4)
  n, c = apply(T, t)
  @test n.a == [3, 2, 1, 4]
  @test n.b == [2, 4, 4, 5]
  @test n.c == [1, 1, 6, 2]
  @test n.d == [4, 3, 7, 5]
  @test n.e == [5, 5, 2, 6]
  @test n.f == [4, 4, 3, 4]
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Filter(row -> row[2] == 4 || row[6] == 4)
  n, c = apply(T, t)
  @test n.a == [3, 2, 1, 4]
  @test n.b == [2, 4, 4, 5]
  @test n.c == [1, 1, 6, 2]
  @test n.d == [4, 3, 7, 5]
  @test n.e == [5, 5, 2, 6]
  @test n.f == [4, 4, 3, 4]
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Filter(row -> row[:b] == 4 || row[:f] == 4)
  n, c = apply(T, t)
  @test n.a == [3, 2, 1, 4]
  @test n.b == [2, 4, 4, 5]
  @test n.c == [1, 1, 6, 2]
  @test n.d == [4, 3, 7, 5]
  @test n.e == [5, 5, 2, 6]
  @test n.f == [4, 4, 3, 4]
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Filter(row -> row["b"] == 4 || row["f"] == 4)
  n, c = apply(T, t)
  @test n.a == [3, 2, 1, 4]
  @test n.b == [2, 4, 4, 5]
  @test n.c == [1, 1, 6, 2]
  @test n.d == [4, 3, 7, 5]
  @test n.e == [5, 5, 2, 6]
  @test n.f == [4, 4, 3, 4]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # reapply test
  T = Filter(row -> all(≤(5), row))
  n1, c1 = apply(T, t)
  n2 = reapply(T, t, c1)
  @test n1 == n2

  # row table
  rt = Tables.rowtable(t)
  T = Filter(row -> row.b == 4 || row.f == 4)
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  rtₒ = revert(T, n, c)
  @test rt == rtₒ
end

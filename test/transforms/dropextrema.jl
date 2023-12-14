@testset "DropExtrema" begin
  @test !isrevertible(DropExtrema(:a))

  a = [6.9, 9.0, 7.8, 0.0, 5.1, 4.8, 1.1, 8.0, 5.4, 7.9]
  b = [7.7, 4.2, 6.3, 1.4, 4.4, 0.5, 3.0, 6.1, 1.9, 1.5]
  c = [6.1, 7.7, 5.7, 2.8, 2.8, 6.7, 8.4, 5.0, 8.9, 1.0]
  d = [1.0, 2.8, 6.2, 1.9, 8.1, 6.2, 4.0, 6.9, 4.1, 1.4]
  e = [1.5, 8.9, 4.1, 1.6, 5.9, 1.3, 4.9, 3.5, 2.4, 6.3]
  f = [1.9, 2.1, 9.0, 6.2, 1.3, 8.9, 6.2, 3.8, 5.1, 2.3]
  t = Table(; a, b, c, d, e, f)

  T = DropExtrema(1)
  n, c = apply(T, t)
  @test n.a == [6.9, 7.8, 5.1, 5.4]
  @test n.b == [7.7, 6.3, 4.4, 1.9]
  @test n.c == [6.1, 5.7, 2.8, 8.9]
  @test n.d == [1.0, 6.2, 8.1, 4.1]
  @test n.e == [1.5, 4.1, 5.9, 2.4]
  @test n.f == [1.9, 9.0, 1.3, 5.1]

  T = DropExtrema(1, 2)
  n, c = apply(T, t)
  @test n.a == [5.1, 5.4]
  @test n.b == [4.4, 1.9]
  @test n.c == [2.8, 8.9]
  @test n.d == [8.1, 4.1]
  @test n.e == [5.9, 2.4]
  @test n.f == [1.3, 5.1]

  T = DropExtrema(:c, low=0.3, high=0.7)
  n, c = apply(T, t)
  @test n.a == [6.9, 7.8, 4.8, 8.0]
  @test n.b == [7.7, 6.3, 0.5, 6.1]
  @test n.c == [6.1, 5.7, 6.7, 5.0]
  @test n.d == [1.0, 6.2, 6.2, 6.9]
  @test n.e == [1.5, 4.1, 1.3, 3.5]
  @test n.f == [1.9, 9.0, 8.9, 3.8]

  T = DropExtrema([:c, :d], low=0.3, high=0.7)
  n, c = apply(T, t)
  @test n.a == [7.8, 4.8]
  @test n.b == [6.3, 0.5]
  @test n.c == [5.7, 6.7]
  @test n.d == [6.2, 6.2]
  @test n.e == [4.1, 1.3]
  @test n.f == [9.0, 8.9]

  T = DropExtrema("e", low=0.2, high=0.8)
  n, c = apply(T, t)
  @test n.a == [7.8, 0.0, 5.1, 1.1, 8.0, 5.4]
  @test n.b == [6.3, 1.4, 4.4, 3.0, 6.1, 1.9]
  @test n.c == [5.7, 2.8, 2.8, 8.4, 5.0, 8.9]
  @test n.d == [6.2, 1.9, 8.1, 4.0, 6.9, 4.1]
  @test n.e == [4.1, 1.6, 5.9, 4.9, 3.5, 2.4]
  @test n.f == [9.0, 6.2, 1.3, 6.2, 3.8, 5.1]

  T = DropExtrema(("e", "f"), low=0.2, high=0.8)
  n, c = apply(T, t)
  @test n.a == [0.0, 1.1, 8.0, 5.4]
  @test n.b == [1.4, 3.0, 6.1, 1.9]
  @test n.c == [2.8, 8.4, 5.0, 8.9]
  @test n.d == [1.9, 4.0, 6.9, 4.1]
  @test n.e == [1.6, 4.9, 3.5, 2.4]
  @test n.f == [6.2, 6.2, 3.8, 5.1]

  # error: invalid quantiles
  @test_throws AssertionError DropExtrema(:a, low=0, high=1.4)
end

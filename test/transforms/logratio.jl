@testset "LogRatio" begin
  @test isrevertible(ALR())
  @test isrevertible(CLR())
  @test isrevertible(ILR())

  a = [1.0, 0.0, 1.0]
  b = [2.0, 2.0, 2.0]
  c = [3.0, 3.0, 0.0]
  t = Table(; a, b, c)

  T = ALR()
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:ARL1, :ARL2)
  @test n == t |> ALR(:c)
  r = revert(T, n, c)
  @test Tables.matrix(r) ≈ Tables.matrix(t)

  T = CLR()
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:CLR1, :CLR2, :CLR3)
  r = revert(T, n, c)
  @test Tables.matrix(r) ≈ Tables.matrix(t)

  T = ILR()
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:ILR1, :ILR2)
  @test n == t |> ILR(:c)
  r = revert(T, n, c)
  @test Tables.matrix(r) ≈ Tables.matrix(t)

  a = [1.0, 0.0, 1.0]
  b = [2.0, 2.0, 2.0]
  c = [3.0, 3.0, 0.0]
  t1 = Table(; a, c, b)
  t2 = Table(; c, a, b)

  T = ALR(:c)
  n1, c1 = apply(T, t1)
  r1 = revert(T, n1, c1)
  n2, c2 = apply(T, t2)
  r2 = revert(T, n2, c2)
  @test n1 == n2
  @test Tables.matrix(r1) ≈ Tables.matrix(t1)
  @test Tables.schema(r1).names == (:a, :c, :b)
  @test Tables.matrix(r2) ≈ Tables.matrix(t2)
  @test Tables.schema(r2).names == (:c, :a, :b)

  T = ILR(:c)
  n1, c1 = apply(T, t1)
  r1 = revert(T, n1, c1)
  n2, c2 = apply(T, t2)
  r2 = revert(T, n2, c2)
  @test n1 == n2
  @test Tables.matrix(r1) ≈ Tables.matrix(t1)
  @test Tables.schema(r1).names == (:a, :c, :b)
  @test Tables.matrix(r2) ≈ Tables.matrix(t2)
  @test Tables.schema(r2).names == (:c, :a, :b)
end

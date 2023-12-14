@testset "Coalesce" begin
  @test !isrevertible(Coalesce(value=0))

  @test TT.parameters(Coalesce(value=0)) == (; value=0)

  a = [3, 2, missing, 4, 5, 3]
  b = [missing, 4, 4, 5, 8, 5]
  c = [1, 1, 6, 2, 4, missing]
  d = [4, 3, 7, 5, 4, missing]
  e = [missing, 5, 2, 6, 5, 2]
  f = [4, missing, 3, 4, 5, 2]
  t = Table(; a, b, c, d, e, f)

  T = Coalesce(value=0)
  n, c = apply(T, t)
  @test n.a == [3, 2, 0, 4, 5, 3]
  @test n.b == [0, 4, 4, 5, 8, 5]
  @test n.c == [1, 1, 6, 2, 4, 0]
  @test n.d == [4, 3, 7, 5, 4, 0]
  @test n.e == [0, 5, 2, 6, 5, 2]
  @test n.f == [4, 0, 3, 4, 5, 2]

  # table schema after apply
  T = Coalesce(value=0)
  n, c = apply(T, t)
  ntypes = Tables.schema(n).types
  @test ntypes[1] == Int
  @test ntypes[2] == Int
  @test ntypes[3] == Int
  @test ntypes[4] == Int
  @test ntypes[5] == Int
  @test ntypes[6] == Int

  # row table
  rt = Tables.rowtable(t)
  T = Coalesce(value=0)
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)

  # colspec
  T = Coalesce(1, 3, 5, value=0)
  n, c = apply(T, t)
  @test n.a == [3, 2, 0, 4, 5, 3]
  @test isequal(n.b, [missing, 4, 4, 5, 8, 5])
  @test n.c == [1, 1, 6, 2, 4, 0]
  @test isequal(n.d, [4, 3, 7, 5, 4, missing])
  @test n.e == [0, 5, 2, 6, 5, 2]
  @test isequal(n.f, [4, missing, 3, 4, 5, 2])

  T = Coalesce([:b, :d, :f], value=0)
  n, c = apply(T, t)
  @test isequal(n.a, [3, 2, missing, 4, 5, 3])
  @test n.b == [0, 4, 4, 5, 8, 5]
  @test isequal(n.c, [1, 1, 6, 2, 4, missing])
  @test n.d == [4, 3, 7, 5, 4, 0]
  @test isequal(n.e, [missing, 5, 2, 6, 5, 2])
  @test n.f == [4, 0, 3, 4, 5, 2]

  T = Coalesce(("a", "c", "e"), value=0)
  n, c = apply(T, t)
  @test n.a == [3, 2, 0, 4, 5, 3]
  @test isequal(n.b, [missing, 4, 4, 5, 8, 5])
  @test n.c == [1, 1, 6, 2, 4, 0]
  @test isequal(n.d, [4, 3, 7, 5, 4, missing])
  @test n.e == [0, 5, 2, 6, 5, 2]
  @test isequal(n.f, [4, missing, 3, 4, 5, 2])

  T = Coalesce(r"[bdf]", value=0)
  n, c = apply(T, t)
  @test isequal(n.a, [3, 2, missing, 4, 5, 3])
  @test n.b == [0, 4, 4, 5, 8, 5]
  @test isequal(n.c, [1, 1, 6, 2, 4, missing])
  @test n.d == [4, 3, 7, 5, 4, 0]
  @test isequal(n.e, [missing, 5, 2, 6, 5, 2])
  @test n.f == [4, 0, 3, 4, 5, 2]
end

@testset "Coalesce" begin
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

  # revert test
  @test isrevertible(T)
  tₒ = revert(T, n, c)
  cols = Tables.columns(t)
  colsₒ = Tables.columns(tₒ)
  colnames = Tables.columnnames(t)
  for n in colnames
    col = Tables.getcolumn(cols, n)
    colₒ = Tables.getcolumn(colsₒ, n)
    @test isequal(col, colₒ)
  end

  # table schema after apply and revert
  T = Coalesce(value=0)
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  ttypes = Tables.schema(t).types
  ntypes = Tables.schema(n).types
  @test ntypes[1] == Int
  @test ntypes[2] == Int
  @test ntypes[3] == Int
  @test ntypes[4] == Int
  @test ntypes[5] == Int
  @test ntypes[6] == Int
  @test ttypes == Tables.schema(tₒ).types

  # row table
  rt = Tables.rowtable(t)
  T = Coalesce(value=0)
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  rtₒ = revert(T, n, c)
  for (row, rowₒ) in zip(rt, rtₒ)
    @test isequal(row, rowₒ)
  end

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

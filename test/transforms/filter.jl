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

@testset "DropMissing" begin
  a = [3, 2, missing, 4, 5, 3]
  b = [missing, 4, 4, 5, 8, 5]
  c = [1, 1, 6, 2, 4, missing]
  d = [4, 3, 7, 5, 4, missing]
  e = [missing, 5, 2, 6, 5, 2]
  f = [4, missing, 3, 4, 5, 2]
  t = Table(; a, b, c, d, e, f)

  T = DropMissing()
  n, c = apply(T, t)
  @test n.a == [4, 5]
  @test n.b == [5, 8]
  @test n.c == [2, 4]
  @test n.d == [5, 4]
  @test n.e == [6, 5]
  @test n.f == [4, 5]

  # revert test
  @test isrevertible(T)
  tₒ = revert(T, n, c)
  cols = Tables.columns(t)
  colsₒ = Tables.columns(tₒ)
  colnames = Tables.columnnames(t)
  for n in colnames
    col = Tables.getcolumn(cols, n)
    colₒ = Tables.getcolumn(colsₒ, n)
    @test isequalmissing(col, colₒ)
  end

  # args...
  # integers
  T = DropMissing(1, 3, 4)
  n, c = apply(T, t)
  @test isequalmissing(n.a, [3, 2, 4, 5])
  @test isequalmissing(n.b, [missing, 4, 5, 8])
  @test isequalmissing(n.c, [1, 1, 2, 4])
  @test isequalmissing(n.d, [4, 3, 5, 4])
  @test isequalmissing(n.e, [missing, 5, 6, 5])
  @test isequalmissing(n.f, [4, missing, 4, 5])

  # symbols
  T = DropMissing(:a, :c, :d)
  n, c = apply(T, t)
  @test isequalmissing(n.a, [3, 2, 4, 5])
  @test isequalmissing(n.b, [missing, 4, 5, 8])
  @test isequalmissing(n.c, [1, 1, 2, 4])
  @test isequalmissing(n.d, [4, 3, 5, 4])
  @test isequalmissing(n.e, [missing, 5, 6, 5])
  @test isequalmissing(n.f, [4, missing, 4, 5])

  # strings
  T = DropMissing("a", "c", "d")
  n, c = apply(T, t)
  @test isequalmissing(n.a, [3, 2, 4, 5])
  @test isequalmissing(n.b, [missing, 4, 5, 8])
  @test isequalmissing(n.c, [1, 1, 2, 4])
  @test isequalmissing(n.d, [4, 3, 5, 4])
  @test isequalmissing(n.e, [missing, 5, 6, 5])
  @test isequalmissing(n.f, [4, missing, 4, 5])

  # vector
  # integers
  T = DropMissing([1, 3, 4])
  n, c = apply(T, t)
  @test isequalmissing(n.a, [3, 2, 4, 5])
  @test isequalmissing(n.b, [missing, 4, 5, 8])
  @test isequalmissing(n.c, [1, 1, 2, 4])
  @test isequalmissing(n.d, [4, 3, 5, 4])
  @test isequalmissing(n.e, [missing, 5, 6, 5])
  @test isequalmissing(n.f, [4, missing, 4, 5])

  # symbols
  T = DropMissing([:a, :c, :d])
  n, c = apply(T, t)
  @test isequalmissing(n.a, [3, 2, 4, 5])
  @test isequalmissing(n.b, [missing, 4, 5, 8])
  @test isequalmissing(n.c, [1, 1, 2, 4])
  @test isequalmissing(n.d, [4, 3, 5, 4])
  @test isequalmissing(n.e, [missing, 5, 6, 5])
  @test isequalmissing(n.f, [4, missing, 4, 5])

  # strings
  T = DropMissing(["a", "c", "d"])
  n, c = apply(T, t)
  @test isequalmissing(n.a, [3, 2, 4, 5])
  @test isequalmissing(n.b, [missing, 4, 5, 8])
  @test isequalmissing(n.c, [1, 1, 2, 4])
  @test isequalmissing(n.d, [4, 3, 5, 4])
  @test isequalmissing(n.e, [missing, 5, 6, 5])
  @test isequalmissing(n.f, [4, missing, 4, 5])

  # tuple
  # integers
  T = DropMissing((1, 3, 4))
  n, c = apply(T, t)
  @test isequalmissing(n.a, [3, 2, 4, 5])
  @test isequalmissing(n.b, [missing, 4, 5, 8])
  @test isequalmissing(n.c, [1, 1, 2, 4])
  @test isequalmissing(n.d, [4, 3, 5, 4])
  @test isequalmissing(n.e, [missing, 5, 6, 5])
  @test isequalmissing(n.f, [4, missing, 4, 5])

  # symbols
  T = DropMissing((:a, :c, :d))
  n, c = apply(T, t)
  @test isequalmissing(n.a, [3, 2, 4, 5])
  @test isequalmissing(n.b, [missing, 4, 5, 8])
  @test isequalmissing(n.c, [1, 1, 2, 4])
  @test isequalmissing(n.d, [4, 3, 5, 4])
  @test isequalmissing(n.e, [missing, 5, 6, 5])
  @test isequalmissing(n.f, [4, missing, 4, 5])

  # strings
  T = DropMissing(("a", "c", "d"))
  n, c = apply(T, t)
  @test isequalmissing(n.a, [3, 2, 4, 5])
  @test isequalmissing(n.b, [missing, 4, 5, 8])
  @test isequalmissing(n.c, [1, 1, 2, 4])
  @test isequalmissing(n.d, [4, 3, 5, 4])
  @test isequalmissing(n.e, [missing, 5, 6, 5])
  @test isequalmissing(n.f, [4, missing, 4, 5])

  # regex
  T = DropMissing(r"[acd]")
  n, c = apply(T, t)
  @test isequalmissing(n.a, [3, 2, 4, 5])
  @test isequalmissing(n.b, [missing, 4, 5, 8])
  @test isequalmissing(n.c, [1, 1, 2, 4])
  @test isequalmissing(n.d, [4, 3, 5, 4])
  @test isequalmissing(n.e, [missing, 5, 6, 5])
  @test isequalmissing(n.f, [4, missing, 4, 5])

  # table schema after apply and revert
  T = DropMissing()
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

  T = DropMissing([:a, :c, :d])
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  ntypes = Tables.schema(n).types
  @test ntypes[1] == Int
  @test ntypes[2] == Union{Missing,Int}
  @test ntypes[3] == Int
  @test ntypes[4] == Int
  @test ntypes[5] == Union{Missing,Int}
  @test ntypes[6] == Union{Missing,Int}
  @test ttypes == Tables.schema(tₒ).types

  T = DropMissing([:b, :e, :f])
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  ntypes = Tables.schema(n).types
  @test ntypes[1] == Union{Missing,Int}
  @test ntypes[2] == Int
  @test ntypes[3] == Union{Missing,Int}
  @test ntypes[4] == Union{Missing,Int}
  @test ntypes[5] == Int
  @test ntypes[6] == Int
  @test ttypes == Tables.schema(tₒ).types

  # reapply test
  T = DropMissing()
  n1, c1 = apply(T, t)
  n2 = reapply(T, t, c1)
  @test n1 == n2

  # row table
  rt = Tables.rowtable(t)
  T = DropMissing()
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  rtₒ = revert(T, n, c)
  for (row, rowₒ) in zip(rt, rtₒ)
    @test isequalmissing(row, rowₒ)
  end

  # missing value columns
  a = fill(missing, 6)
  b = [missing, 4, 4, 5, 8, 5]
  c = [1, 1, 6, 2, 4, missing]
  d = [4, 3, 7, 5, 4, missing]
  e = [missing, 5, 2, 6, 5, 2]
  f = fill(missing, 6)
  t = Table(; a, b, c, d, e, f)

  T = DropMissing()
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  ttypes = Tables.schema(t).types
  ntypes = Tables.schema(n).types
  @test isequal(n.a, [])
  @test isequal(n.b, [])
  @test isequal(n.c, [])
  @test isequal(n.d, [])
  @test isequal(n.e, [])
  @test isequal(n.f, [])
  @test ntypes[1] == Any
  @test ntypes[2] == Int
  @test ntypes[3] == Int
  @test ntypes[4] == Int
  @test ntypes[5] == Int
  @test ntypes[6] == Any
  @test ttypes == Tables.schema(tₒ).types

  T = DropMissing(:a)
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  ttypes = Tables.schema(t).types
  ntypes = Tables.schema(n).types
  @test isequal(n.a, [])
  @test isequal(n.b, [])
  @test isequal(n.c, [])
  @test isequal(n.d, [])
  @test isequal(n.e, [])
  @test isequal(n.f, [])
  @test ntypes[1] == Any
  @test ntypes[2] == Union{Missing,Int}
  @test ntypes[3] == Union{Missing,Int}
  @test ntypes[4] == Union{Missing,Int}
  @test ntypes[5] == Union{Missing,Int}
  @test ntypes[6] == Missing
  @test ttypes == Tables.schema(tₒ).types

  T = DropMissing(:f)
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  ttypes = Tables.schema(t).types
  ntypes = Tables.schema(n).types
  @test isequal(n.a, [])
  @test isequal(n.b, [])
  @test isequal(n.c, [])
  @test isequal(n.d, [])
  @test isequal(n.e, [])
  @test isequal(n.f, [])
  @test ntypes[1] == Missing
  @test ntypes[2] == Union{Missing,Int}
  @test ntypes[3] == Union{Missing,Int}
  @test ntypes[4] == Union{Missing,Int}
  @test ntypes[5] == Union{Missing,Int}
  @test ntypes[6] == Any
  @test ttypes == Tables.schema(tₒ).types

  T = DropMissing(:b, :c, :d, :e)
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  ttypes = Tables.schema(t).types
  ntypes = Tables.schema(n).types
  @test isequal(n.a, fill(missing, 4))
  @test isequal(n.b, [4, 4, 5, 8])
  @test isequal(n.c, [1, 6, 2, 4])
  @test isequal(n.d, [3, 7, 5, 4])
  @test isequal(n.e, [5, 2, 6, 5])
  @test isequal(n.f, fill(missing, 4))
  @test ntypes[1] == Missing
  @test ntypes[2] == Int
  @test ntypes[3] == Int
  @test ntypes[4] == Int
  @test ntypes[5] == Int
  @test ntypes[6] == Missing
  @test ttypes == Tables.schema(tₒ).types

  # throws: empty tuple
  @test_throws ArgumentError DropMissing(())

  # throws: empty selection
  @test_throws AssertionError apply(DropMissing(r"g"), t)
  @test_throws AssertionError DropMissing(Symbol[])
  @test_throws AssertionError DropMissing(String[])

  # throws: columns that do not exist in the original table
  @test_throws AssertionError apply(DropMissing(:g, :h), t)
  @test_throws AssertionError apply(DropMissing([:g, :h]), t)
  @test_throws AssertionError apply(DropMissing((:g, :h)), t)
  @test_throws AssertionError apply(DropMissing("g", "h"), t)
  @test_throws AssertionError apply(DropMissing(["g", "h"]), t)
  @test_throws AssertionError apply(DropMissing(("g", "h")), t)
end

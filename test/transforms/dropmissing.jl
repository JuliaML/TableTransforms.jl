@testset "DropMissing" begin
  @test !isrevertible(DropMissing())

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

  # args...
  # integers
  T = DropMissing(1, 3, 4)
  n, c = apply(T, t)
  @test isequal(n.a, [3, 2, 4, 5])
  @test isequal(n.b, [missing, 4, 5, 8])
  @test isequal(n.c, [1, 1, 2, 4])
  @test isequal(n.d, [4, 3, 5, 4])
  @test isequal(n.e, [missing, 5, 6, 5])
  @test isequal(n.f, [4, missing, 4, 5])

  # symbols
  T = DropMissing(:a, :c, :d)
  n, c = apply(T, t)
  @test isequal(n.a, [3, 2, 4, 5])
  @test isequal(n.b, [missing, 4, 5, 8])
  @test isequal(n.c, [1, 1, 2, 4])
  @test isequal(n.d, [4, 3, 5, 4])
  @test isequal(n.e, [missing, 5, 6, 5])
  @test isequal(n.f, [4, missing, 4, 5])

  # strings
  T = DropMissing("a", "c", "d")
  n, c = apply(T, t)
  @test isequal(n.a, [3, 2, 4, 5])
  @test isequal(n.b, [missing, 4, 5, 8])
  @test isequal(n.c, [1, 1, 2, 4])
  @test isequal(n.d, [4, 3, 5, 4])
  @test isequal(n.e, [missing, 5, 6, 5])
  @test isequal(n.f, [4, missing, 4, 5])

  # vector
  # integers
  T = DropMissing([1, 3, 4])
  n, c = apply(T, t)
  @test isequal(n.a, [3, 2, 4, 5])
  @test isequal(n.b, [missing, 4, 5, 8])
  @test isequal(n.c, [1, 1, 2, 4])
  @test isequal(n.d, [4, 3, 5, 4])
  @test isequal(n.e, [missing, 5, 6, 5])
  @test isequal(n.f, [4, missing, 4, 5])

  # symbols
  T = DropMissing([:a, :c, :d])
  n, c = apply(T, t)
  @test isequal(n.a, [3, 2, 4, 5])
  @test isequal(n.b, [missing, 4, 5, 8])
  @test isequal(n.c, [1, 1, 2, 4])
  @test isequal(n.d, [4, 3, 5, 4])
  @test isequal(n.e, [missing, 5, 6, 5])
  @test isequal(n.f, [4, missing, 4, 5])

  # strings
  T = DropMissing(["a", "c", "d"])
  n, c = apply(T, t)
  @test isequal(n.a, [3, 2, 4, 5])
  @test isequal(n.b, [missing, 4, 5, 8])
  @test isequal(n.c, [1, 1, 2, 4])
  @test isequal(n.d, [4, 3, 5, 4])
  @test isequal(n.e, [missing, 5, 6, 5])
  @test isequal(n.f, [4, missing, 4, 5])

  # tuple
  # integers
  T = DropMissing((1, 3, 4))
  n, c = apply(T, t)
  @test isequal(n.a, [3, 2, 4, 5])
  @test isequal(n.b, [missing, 4, 5, 8])
  @test isequal(n.c, [1, 1, 2, 4])
  @test isequal(n.d, [4, 3, 5, 4])
  @test isequal(n.e, [missing, 5, 6, 5])
  @test isequal(n.f, [4, missing, 4, 5])

  # symbols
  T = DropMissing((:a, :c, :d))
  n, c = apply(T, t)
  @test isequal(n.a, [3, 2, 4, 5])
  @test isequal(n.b, [missing, 4, 5, 8])
  @test isequal(n.c, [1, 1, 2, 4])
  @test isequal(n.d, [4, 3, 5, 4])
  @test isequal(n.e, [missing, 5, 6, 5])
  @test isequal(n.f, [4, missing, 4, 5])

  # strings
  T = DropMissing(("a", "c", "d"))
  n, c = apply(T, t)
  @test isequal(n.a, [3, 2, 4, 5])
  @test isequal(n.b, [missing, 4, 5, 8])
  @test isequal(n.c, [1, 1, 2, 4])
  @test isequal(n.d, [4, 3, 5, 4])
  @test isequal(n.e, [missing, 5, 6, 5])
  @test isequal(n.f, [4, missing, 4, 5])

  # regex
  T = DropMissing(r"[acd]")
  n, c = apply(T, t)
  @test isequal(n.a, [3, 2, 4, 5])
  @test isequal(n.b, [missing, 4, 5, 8])
  @test isequal(n.c, [1, 1, 2, 4])
  @test isequal(n.d, [4, 3, 5, 4])
  @test isequal(n.e, [missing, 5, 6, 5])
  @test isequal(n.f, [4, missing, 4, 5])

  # table schema after apply and revert
  T = DropMissing()
  n, c = apply(T, t)
  ntypes = Tables.schema(n).types
  @test ntypes[1] == Int
  @test ntypes[2] == Int
  @test ntypes[3] == Int
  @test ntypes[4] == Int
  @test ntypes[5] == Int
  @test ntypes[6] == Int

  T = DropMissing([:a, :c, :d])
  n, c = apply(T, t)
  ntypes = Tables.schema(n).types
  @test ntypes[1] == Int
  @test ntypes[2] == Union{Missing,Int}
  @test ntypes[3] == Int
  @test ntypes[4] == Int
  @test ntypes[5] == Union{Missing,Int}
  @test ntypes[6] == Union{Missing,Int}

  T = DropMissing([:b, :e, :f])
  n, c = apply(T, t)
  ntypes = Tables.schema(n).types
  @test ntypes[1] == Union{Missing,Int}
  @test ntypes[2] == Int
  @test ntypes[3] == Union{Missing,Int}
  @test ntypes[4] == Union{Missing,Int}
  @test ntypes[5] == Int
  @test ntypes[6] == Int

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

  T = DropMissing(:a)
  n, c = apply(T, t)
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

  T = DropMissing(:f)
  n, c = apply(T, t)
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

  T = DropMissing(:b, :c, :d, :e)
  n, c = apply(T, t)
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

  # throws: empty selection
  @test_throws ArgumentError DropMissing(())
  @test_throws ArgumentError DropMissing(Symbol[])
  @test_throws ArgumentError DropMissing(String[])

  # throws: regex doesn't match any names in input table
  @test_throws AssertionError apply(DropMissing(r"g"), t)

  # throws: columns that do not exist in the original table
  @test_throws AssertionError apply(DropMissing(:g, :h), t)
  @test_throws AssertionError apply(DropMissing([:g, :h]), t)
  @test_throws AssertionError apply(DropMissing((:g, :h)), t)
  @test_throws AssertionError apply(DropMissing("g", "h"), t)
  @test_throws AssertionError apply(DropMissing(["g", "h"]), t)
  @test_throws AssertionError apply(DropMissing(("g", "h")), t)
end

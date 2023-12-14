@testset "Replace" begin
  @test !isrevertible(Replace(1 => -1, 5 => -5))

  a = [3, 2, 1, 4, 5, 3]
  b = [2, 4, 4, 5, 8, 5]
  c = [1, 1, 6, 2, 4, 1]
  d = [4, 3, 7, 5, 4, 1]
  e = [5, 5, 2, 6, 5, 2]
  f = [4, 4, 3, 4, 5, 2]
  t = Table(; a, b, c, d, e, f)

  # replace with a value of the same type
  T = Replace(1 => -1, 5 => -5)
  n, c = apply(T, t)
  @test n.a == [3, 2, -1, 4, -5, 3]
  @test n.b == [2, 4, 4, -5, 8, -5]
  @test n.c == [-1, -1, 6, 2, 4, -1]
  @test n.d == [4, 3, 7, -5, 4, -1]
  @test n.e == [-5, -5, 2, 6, -5, 2]
  @test n.f == [4, 4, 3, 4, -5, 2]

  # with colspec
  T = Replace(2 => 4 => -4, :c => 1 => -1, "e" => 5 => -5)
  n, c = apply(T, t)
  @test n.a == [3, 2, 1, 4, 5, 3]
  @test n.b == [2, -4, -4, 5, 8, 5]
  @test n.c == [-1, -1, 6, 2, 4, -1]
  @test n.d == [4, 3, 7, 5, 4, 1]
  @test n.e == [-5, -5, 2, 6, -5, 2]
  @test n.f == [4, 4, 3, 4, 5, 2]

  T = Replace([2, 5] => 5 => -5)
  n, c = apply(T, t)
  @test n.a == [3, 2, 1, 4, 5, 3]
  @test n.b == [2, 4, 4, -5, 8, -5]
  @test n.c == [1, 1, 6, 2, 4, 1]
  @test n.d == [4, 3, 7, 5, 4, 1]
  @test n.e == [-5, -5, 2, 6, -5, 2]
  @test n.f == [4, 4, 3, 4, 5, 2]

  T = Replace([:b, :e] => 5 => -5)
  n, c = apply(T, t)
  @test n.a == [3, 2, 1, 4, 5, 3]
  @test n.b == [2, 4, 4, -5, 8, -5]
  @test n.c == [1, 1, 6, 2, 4, 1]
  @test n.d == [4, 3, 7, 5, 4, 1]
  @test n.e == [-5, -5, 2, 6, -5, 2]
  @test n.f == [4, 4, 3, 4, 5, 2]

  T = Replace(["b", "e"] => 5 => -5)
  n, c = apply(T, t)
  @test n.a == [3, 2, 1, 4, 5, 3]
  @test n.b == [2, 4, 4, -5, 8, -5]
  @test n.c == [1, 1, 6, 2, 4, 1]
  @test n.d == [4, 3, 7, 5, 4, 1]
  @test n.e == [-5, -5, 2, 6, -5, 2]
  @test n.f == [4, 4, 3, 4, 5, 2]

  T = Replace(r"[be]" => 5 => -5)
  n, c = apply(T, t)
  @test n.a == [3, 2, 1, 4, 5, 3]
  @test n.b == [2, 4, 4, -5, 8, -5]
  @test n.c == [1, 1, 6, 2, 4, 1]
  @test n.d == [4, 3, 7, 5, 4, 1]
  @test n.e == [-5, -5, 2, 6, -5, 2]
  @test n.f == [4, 4, 3, 4, 5, 2]

  # with predicates
  T = Replace([:b, :d] => >(4) => 0)
  n, c = apply(T, t)
  @test n.a == [3, 2, 1, 4, 5, 3]
  @test n.b == [2, 4, 4, 0, 0, 0]
  @test n.c == [1, 1, 6, 2, 4, 1]
  @test n.d == [4, 3, 0, 0, 4, 1]
  @test n.e == [5, 5, 2, 6, 5, 2]
  @test n.f == [4, 4, 3, 4, 5, 2]

  T = Replace([:a, :f] => (x -> 1 < x < 5) => 0)
  n, c = apply(T, t)
  @test n.a == [0, 0, 1, 0, 5, 0]
  @test n.b == [2, 4, 4, 5, 8, 5]
  @test n.c == [1, 1, 6, 2, 4, 1]
  @test n.d == [4, 3, 7, 5, 4, 1]
  @test n.e == [5, 5, 2, 6, 5, 2]
  @test n.f == [0, 0, 0, 0, 5, 0]

  # table schema after apply
  T = Replace(1 => -1, 5 => -5)
  n, c = apply(T, t)
  types = Tables.schema(t).types
  @test types == Tables.schema(n).types

  # replace with a value of another type
  T = Replace(1 => 1.5, 5 => 5.5, 4 => true)
  n, c = apply(T, t)
  @test n.a == Real[3, 2, 1.5, true, 5.5, 3]
  @test n.b == Real[2, true, true, 5.5, 8, 5.5]
  @test n.c == Real[1.5, 1.5, 6, 2, true, 1.5]
  @test n.d == Real[true, 3, 7, 5.5, true, 1.5]
  @test n.e == Real[5.5, 5.5, 2, 6, 5.5, 2]
  @test n.f == Real[true, true, 3, true, 5.5, 2]

  # table schema after apply
  T = Replace(1 => 1.5, 5 => 5.5, 4 => true)
  n, c = apply(T, t)
  ntypes = Tables.schema(n).types
  @test ntypes[1] == Real
  @test ntypes[2] == Real
  @test ntypes[3] == Real
  @test ntypes[4] == Real
  @test ntypes[5] == Real
  @test ntypes[6] == Real

  # no occurrences
  T = Replace(10 => 11, 20 => 30)
  n, c = apply(T, t)
  @test t == n

  # columns with different types
  a = [3, 2, 1, 4, 5, 3]
  b = [2.5, 4.5, 4.7, 2.5, 2.5, 5.3]
  c = [true, false, false, false, true, false]
  d = ['a', 'b', 'c', 'd', 'e', 'a']
  t = Table(; a, b, c, d)

  T = Replace(3 => -3, 2.5 => 2.0, true => false, 'a' => 'A')
  n, c = apply(T, t)
  @test n.a == [-3, 2, 1, 4, 5, -3]
  @test n.b == [2.0, 4.5, 4.7, 2.0, 2.0, 5.3]
  @test n.c == [false, false, false, false, false, false]
  @test n.d == ['A', 'b', 'c', 'd', 'e', 'A']

  # row table
  rt = Tables.rowtable(t)
  T = Replace(3 => -3, 2.5 => 2.0)
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)

  # throws
  @test_throws ArgumentError Replace()
end

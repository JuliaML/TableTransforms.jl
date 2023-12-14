@testset "Map" begin
  @test !isrevertible(Map(:a => sin))

  a = [4, 7, 8, 5, 8, 1]
  b = [1, 9, 1, 7, 9, 4]
  c = [2, 8, 6, 3, 2, 2]
  d = [7, 5, 9, 5, 3, 4]
  t = Table(; a, b, c, d)

  T = Map(1 => sin)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :a_sin)
  @test n.a_sin == sin.(t.a)

  T = Map(:b => cos)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :b_cos)
  @test n.b_cos == cos.(t.b)

  T = Map("c" => tan)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :c_tan)
  @test n.c_tan == tan.(t.c)

  T = Map(:a => sin => :a)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d)
  @test n.a == sin.(t.a)

  T = Map(:a => sin => "a")
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d)
  @test n.a == sin.(t.a)

  T = Map([2, 3] => ((b, c) -> 2b + c) => :op1)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :op1)
  @test n.op1 == @. 2 * t.b + t.c

  T = Map([:a, :c] => ((a, c) -> 2a * 3c) => :op1)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :op1)
  @test n.op1 == @. 2 * t.a * 3 * t.c

  T = Map(["c", "a"] => ((c, a) -> 3c / a) => :op1, "c" => tan)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :op1, :c_tan)
  @test n.op1 == @. 3 * t.c / t.a
  @test n.c_tan == tan.(t.c)

  T = Map(r"[abc]" => ((a, b, c) -> a^2 - 2b + c) => "op1")
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :op1)
  @test n.op1 == @. t.a^2 - 2 * t.b + t.c

  # throws
  @test_throws ArgumentError Map()
end

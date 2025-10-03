@testset "Map" begin
  @test !isrevertible(Map(:a => sin))

  a = [4, 7, 8, 5, 8, 1]
  b = [1, 9, 1, 7, 9, 4]
  c = [2, 8, 6, 3, 2, 2]
  d = [7, 5, 9, 5, 3, 4]
  t = Table(; a, b, c, d)

  T = Map(1 => sin)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:sin_a,)
  @test n.sin_a == sin.(t.a)

  T = Map(:b => cos)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:cos_b,)
  @test n.cos_b == cos.(t.b)

  T = Map("c" => tan)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:tan_c,)
  @test n.tan_c == tan.(t.c)

  T = Map(:a => sin => :a)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a,)
  @test n.a == sin.(t.a)

  T = Map(:a => sin => "a")
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a,)
  @test n.a == sin.(t.a)

  T = Map([2, 3] => ((b, c) -> 2b + c) => :op1)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:op1,)
  @test n.op1 == @. 2 * t.b + t.c

  T = Map([:a, :c] => ((a, c) -> 2a * 3c) => :op1)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:op1,)
  @test n.op1 == @. 2 * t.a * 3 * t.c

  T = Map(["c", "a"] => ((c, a) -> 3c / a) => :op1, "c" => tan)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:op1, :tan_c)
  @test n.op1 == @. 3 * t.c / t.a
  @test n.tan_c == tan.(t.c)

  T = Map(r"[abc]" => ((a, b, c) -> a^2 - 2b + c) => "op1")
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:op1,)
  @test n.op1 == @. t.a^2 - 2 * t.b + t.c

  # generated names
  # normal function
  T = Map([:c, :d] => hypot)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:hypot_c_d,)
  @test n.hypot_c_d == hypot.(t.c, t.d)

  # anonymous function
  f = a -> a^2 + 3
  fname = replace(string(f), "#" => "f")
  colname = Symbol(fname, :_a)
  T = Map(:a => f)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (colname,)
  @test Tables.getcolumn(n, colname) == f.(t.a)

  # composed function
  f = sin ∘ cos
  T = Map(:b => f)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:sin_cos_b,)
  @test n.sin_cos_b == f.(t.b)

  f = sin ∘ cos ∘ tan
  T = Map(:c => sin ∘ cos ∘ tan)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:sin_cos_tan_c,)
  @test n.sin_cos_tan_c == f.(t.c)

  # Base.Fix1
  f = Base.Fix1(hypot, 2)
  T = Map(:d => f)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:fix1_hypot_d,)
  @test n.fix1_hypot_d == f.(t.d)

  # Base.Fix2
  f = Base.Fix2(hypot, 2)
  T = Map(:a => f)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:fix2_hypot_a,)
  @test n.fix2_hypot_a == f.(t.a)

  # function and target
  f = (a, b, c, d) -> a + b + c + d
  T = Map(f => "target")
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:target,)
  @test n.target == f.(t.a, t.b, t.c, t.d)

  # function alone
  f = (a, b, c, d) -> a + b + c + d
  fname = replace(string(f), "#" => "f")
  colname = Symbol(fname, :_a, :_b, :_c, :_d)
  T = Map(f)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (colname,)
  @test Tables.getcolumn(n, colname) == f.(t.a, t.b, t.c, t.d)

  # type and target
  struct Foo a; b; c; d end
  T = Map(Foo => "target")
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:target,)
  @test n.target == Foo.(t.a, t.b, t.c, t.d)

  # type alone
  struct Bar a; b; c; d end
  T = Map(Bar)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:Bar_a_b_c_d,)
  @test n.Bar_a_b_c_d == Bar.(t.a, t.b, t.c, t.d)

  # error: cannot create Map transform without arguments
  @test_throws ArgumentError Map()
end

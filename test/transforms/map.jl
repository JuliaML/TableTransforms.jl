@testset "Map" begin
  @test !isrevertible(Map(:a => sin))

  a = [4, 7, 8, 5, 8, 1]
  b = [1, 9, 1, 7, 9, 4]
  c = [2, 8, 6, 3, 2, 2]
  d = [7, 5, 9, 5, 3, 4]
  t = Table(; a, b, c, d)

  T = Map(1 => sin)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :sin_a)
  @test n.sin_a == sin.(t.a)

  T = Map(:b => cos)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :cos_b)
  @test n.cos_b == cos.(t.b)

  T = Map("c" => tan)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :tan_c)
  @test n.tan_c == tan.(t.c)

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
  @test Tables.schema(n).names == (:a, :b, :c, :d, :op1, :tan_c)
  @test n.op1 == @. 3 * t.c / t.a
  @test n.tan_c == tan.(t.c)

  T = Map(r"[abc]" => ((a, b, c) -> a^2 - 2b + c) => "op1")
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :op1)
  @test n.op1 == @. t.a^2 - 2 * t.b + t.c

  # generated names
  # normal function
  T = Map([:c, :d] => hypot)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :hypot_c_d)
  @test n.hypot_c_d == hypot.(t.c, t.d)

  # anonymous function
  f = a -> a^2 + 3
  fname = replace(string(f), "#" => "f")
  colname = Symbol(fname, :_a)
  T = Map(:a => f)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, colname)
  @test Tables.getcolumn(n, colname) == f.(t.a)

  # composed function
  f = sin ∘ cos
  T = Map(:b => f)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :sin_cos_b)
  @test n.sin_cos_b == f.(t.b)

  f = sin ∘ cos ∘ tan
  T = Map(:c => sin ∘ cos ∘ tan)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :sin_cos_tan_c)
  @test n.sin_cos_tan_c == f.(t.c)

  # Base.Fix1
  f = Base.Fix1(hypot, 2)
  T = Map(:d => f)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :fix1_hypot_d)
  @test n.fix1_hypot_d == f.(t.d)

  # Base.Fix2
  f = Base.Fix2(hypot, 2)
  T = Map(:a => f)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :fix2_hypot_a)
  @test n.fix2_hypot_a == f.(t.a)

  # error: cannot create Map transform without arguments
  @test_throws ArgumentError Map()

  # row functions
  ## no target
  frow = row -> row.a + row.b - row.c
  fname = replace(string(frow), "#" => "f")
  colname = Symbol(fname, :_a,:_b,:_c,:_d)
  T = Map(frow)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, colname)
  @test Tables.getcolumn(n, colname) == frow.(t)

  ## no target with extra functions
  T = Map(frow, :a => (a->a) => :A)
  n, c = apply(T, t)
  Tables.schema(n).names == (:a, :b, :c, :d, colname,:A)
  Tables.getcolumn(n, colname) == frow.(t)

  ## target column
  T = Map((row -> sum(row)) => :summation)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :summation)
  @test map(row->sum(row),t) == n.summation

  ## target column with extra function
  T = Map((row -> row.a + row.b) => :a_plus_b, :a => (a -> a) => :A)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :a_plus_b,:A)
  @test map(row->row.a + row.b,t) == n.a_plus_b

end

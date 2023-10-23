@testset "OneHot" begin
  a = Bool[0, 1, 1, 0, 1, 1]
  b = ["m", "f", "m", "m", "m", "f"]
  c = [3, 2, 2, 1, 1, 3]
  d = categorical(a)
  e = categorical(b)
  f = categorical(c)
  t = Table(; a, b, c, d, e, f)

  T = OneHot(1; categ=true)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a_false, :a_true, :b, :c, :d, :e, :f)
  @test n.a_false == categorical(Bool[1, 0, 0, 1, 0, 0])
  @test n.a_true == categorical(Bool[0, 1, 1, 0, 1, 1])
  @test n.a_false isa CategoricalVector{Bool}
  @test n.a_true isa CategoricalVector{Bool}
  tₒ = revert(T, n, c)
  @test Tables.schema(tₒ) == Tables.schema(t)
  @test tₒ == t

  T = OneHot(:b; categ=true)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a, :b_f, :b_m, :c, :d, :e, :f)
  @test n.b_f == categorical(Bool[0, 1, 0, 0, 0, 1])
  @test n.b_m == categorical(Bool[1, 0, 1, 1, 1, 0])
  @test n.b_f isa CategoricalVector{Bool}
  @test n.b_m isa CategoricalVector{Bool}
  tₒ = revert(T, n, c)
  @test Tables.schema(tₒ) == Tables.schema(t)
  @test tₒ == t

  T = OneHot("c"; categ=true)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a, :b, :c_1, :c_2, :c_3, :d, :e, :f)
  @test n.c_1 == categorical(Bool[0, 0, 0, 1, 1, 0])
  @test n.c_2 == categorical(Bool[0, 1, 1, 0, 0, 0])
  @test n.c_3 == categorical(Bool[1, 0, 0, 0, 0, 1])
  @test n.c_1 isa CategoricalVector{Bool}
  @test n.c_2 isa CategoricalVector{Bool}
  @test n.c_3 isa CategoricalVector{Bool}
  tₒ = revert(T, n, c)
  @test Tables.schema(tₒ) == Tables.schema(t)
  @test tₒ == t

  T = OneHot(4; categ=false)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a, :b, :c, :d_false, :d_true, :e, :f)
  @test n.d_false == Bool[1, 0, 0, 1, 0, 0]
  @test n.d_true == Bool[0, 1, 1, 0, 1, 1]
  tₒ = revert(T, n, c)
  @test Tables.schema(tₒ) == Tables.schema(t)
  @test tₒ == t

  T = OneHot(:e; categ=false)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a, :b, :c, :d, :e_f, :e_m, :f)
  @test n.e_f == Bool[0, 1, 0, 0, 0, 1]
  @test n.e_m == Bool[1, 0, 1, 1, 1, 0]
  tₒ = revert(T, n, c)
  @test Tables.schema(tₒ) == Tables.schema(t)
  @test tₒ == t

  T = OneHot("f"; categ=false)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a, :b, :c, :d, :e, :f_1, :f_2, :f_3)
  @test n.f_1 == Bool[0, 0, 0, 1, 1, 0]
  @test n.f_2 == Bool[0, 1, 1, 0, 0, 0]
  @test n.f_3 == Bool[1, 0, 0, 0, 0, 1]
  tₒ = revert(T, n, c)
  @test Tables.schema(tₒ) == Tables.schema(t)
  @test tₒ == t

  # name formatting
  b = categorical(["m", "f", "m", "m", "m", "f"])
  b_f = rand(6)
  b_m = rand(6)
  t = Table(; b, b_f, b_m)

  T = OneHot(:b; categ=false)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:b_f_, :b_m_, :b_f, :b_m)
  @test n.b_f_ == Bool[0, 1, 0, 0, 0, 1]
  @test n.b_m_ == Bool[1, 0, 1, 1, 1, 0]
  tₒ = revert(T, n, c)
  @test t == tₒ

  b = categorical(["m", "f", "m", "m", "m", "f"])
  b_f = rand(6)
  b_m = rand(6)
  b_f_ = rand(6)
  b_m_ = rand(6)
  t = Table(; b, b_f, b_m, b_f_, b_m_)

  T = OneHot(:b; categ=false)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:b_f__, :b_m__, :b_f, :b_m, :b_f_, :b_m_)
  @test n.b_f__ == Bool[0, 1, 0, 0, 0, 1]
  @test n.b_m__ == Bool[1, 0, 1, 1, 1, 0]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # throws
  a = Bool[0, 1, 1, 0, 1, 1]
  b = rand(6)
  t = Table(; a, b)

  # non categorical column
  @test_throws AssertionError apply(OneHot(:b), t)
  @test_throws AssertionError apply(OneHot("b"), t)

  # invalid column selection
  @test_throws AssertionError apply(OneHot(:c), t)
  @test_throws AssertionError apply(OneHot("c"), t)
end

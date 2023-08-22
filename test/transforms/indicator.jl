@testset "Indicator" begin
  a = [5.8, 6.4, 6.4, 9.8, 7.6, 8.2, 4.5, 2.5, 1.7, 2.3]
  b = [8.4, 1.4, 7.2, 1.8, 9.4, 1.0, 2.0, 5.2, 9.4, 6.2]
  c = [4.1, 5.6, 7.1, 9.1, 5.9, 9.5, 5.7, 9.0, 6.6, 9.9]
  d = [7.5, 2.2, 1.6, 2.8, 1.2, 1.5, 3.7, 2.0, 8.3, 8.2]
  t = Table(; a, b, c, d)

  T = Indicator(:a; scale=:quantile, k=1)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a_1, :b, :c, :d)
  @test n.a_1 == Bool[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  @test n.a_1 isa BitVector
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Indicator(:b; scale=:quantile, k=2)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a, :b_1, :b_2, :c, :d)
  @test n.b_1 == Bool[0, 1, 0, 1, 0, 1, 1, 1, 0, 0]
  @test n.b_2 == Bool[1, 0, 1, 0, 1, 0, 0, 0, 1, 1]
  @test n.b_1 isa BitVector
  @test n.b_2 isa BitVector
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Indicator(:c; scale=:quantile, categ=true, k=3)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a, :b, :c_1, :c_2, :c_3, :d)
  @test n.c_1 == categorical(Bool[1, 1, 0, 0, 1, 0, 1, 0, 0, 0])
  @test n.c_2 == categorical(Bool[0, 0, 1, 0, 0, 0, 0, 0, 1, 0])
  @test n.c_3 == categorical(Bool[0, 0, 0, 1, 0, 1, 0, 1, 0, 1])
  @test n.c_1 isa CategoricalVector{Bool}
  @test n.c_2 isa CategoricalVector{Bool}
  @test n.c_3 isa CategoricalVector{Bool}
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Indicator(:d; scale=:quantile, categ=true, k=4)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a, :b, :c, :d_1, :d_2, :d_3, :d_4)
  @test n.d_1 == categorical(Bool[0, 0, 1, 0, 1, 1, 0, 0, 0, 0])
  @test n.d_2 == categorical(Bool[0, 1, 0, 0, 0, 0, 0, 1, 0, 0])
  @test n.d_3 == categorical(Bool[0, 0, 0, 1, 0, 0, 1, 0, 0, 0])
  @test n.d_4 == categorical(Bool[1, 0, 0, 0, 0, 0, 0, 0, 1, 1])
  @test n.d_1 isa CategoricalVector{Bool}
  @test n.d_2 isa CategoricalVector{Bool}
  @test n.d_3 isa CategoricalVector{Bool}
  @test n.d_4 isa CategoricalVector{Bool}
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Indicator(:a; scale=:linear, k=1)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a_1, :b, :c, :d)
  @test n.a_1 == Bool[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  @test n.a_1 isa BitVector
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Indicator(:b; scale=:linear, k=2)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a, :b_1, :b_2, :c, :d)
  @test n.b_1 == Bool[0, 1, 0, 1, 0, 1, 1, 1, 0, 0]
  @test n.b_2 == Bool[1, 0, 1, 0, 1, 0, 0, 0, 1, 1]
  @test n.b_1 isa BitVector
  @test n.b_2 isa BitVector
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Indicator(:c; scale=:linear, categ=true, k=3)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a, :b, :c_1, :c_2, :c_3, :d)
  @test n.c_1 == categorical(Bool[1, 1, 0, 0, 1, 0, 1, 0, 0, 0])
  @test n.c_2 == categorical(Bool[0, 0, 1, 0, 0, 0, 0, 0, 1, 0])
  @test n.c_3 == categorical(Bool[0, 0, 0, 1, 0, 1, 0, 1, 0, 1])
  @test n.c_1 isa CategoricalVector{Bool}
  @test n.c_2 isa CategoricalVector{Bool}
  @test n.c_3 isa CategoricalVector{Bool}
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Indicator(:d; scale=:linear, categ=true, k=4)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == (:a, :b, :c, :d_1, :d_2, :d_3, :d_4)
  @test n.d_1 == categorical(Bool[0, 1, 1, 1, 1, 1, 0, 1, 0, 0])
  @test n.d_2 == categorical(Bool[0, 0, 0, 0, 0, 0, 1, 0, 0, 0])
  @test n.d_3 == categorical(Bool[0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
  @test n.d_4 == categorical(Bool[1, 0, 0, 0, 0, 0, 0, 0, 1, 1])
  @test n.d_1 isa CategoricalVector{Bool}
  @test n.d_2 isa CategoricalVector{Bool}
  @test n.d_3 isa CategoricalVector{Bool}
  @test n.d_4 isa CategoricalVector{Bool}
  tₒ = revert(T, n, c)
  @test t == tₒ

  @test_throws ArgumentError Indicator(:a, k=0)
  @test_throws ArgumentError Indicator(:a, scale=:test)
end

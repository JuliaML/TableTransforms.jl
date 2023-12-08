@testset "Satisfies" begin
  @test isrevertible(Satisfies(allunique))

  a = [1, 2, 3, 4, 5, 6]
  b = [6, 5, 4, 3, 2, 1]
  c = [1, 2, 3, 4, 6, 6]
  d = [6, 6, 4, 3, 2, 1]
  t = Table(; a, b, c, d)

  T = Satisfies(allunique)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b)
  @test Tables.getcolumn(n, :a) == t.a
  @test Tables.getcolumn(n, :b) == t.b
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Satisfies(x -> sum(x) > 21)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:c, :d)
  @test Tables.getcolumn(n, :c) == t.c
  @test Tables.getcolumn(n, :d) == t.d
  tₒ = revert(T, n, c)
  @test t == tₒ
end

@testset "Only" begin
  a = rand(10)
  b = rand(Float32, 10)
  c = rand(1:9, 10)
  d = rand('a':'z', 10)
  t = Table(; a, b, c, d)

  T = Only(DST.Continuous)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b)
  @test Tables.getcolumn(n, :a) == t.a
  @test Tables.getcolumn(n, :b) == t.b
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Only(DST.Categorical)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:c, :d)
  @test Tables.getcolumn(n, :c) == t.c
  @test Tables.getcolumn(n, :d) == t.d
  tₒ = revert(T, n, c)
  @test t == tₒ
end

@testset "Except" begin
  a = rand(10)
  b = rand(Float32, 10)
  c = rand(1:9, 10)
  d = rand('a':'z', 10)
  t = Table(; a, b, c, d)

  T = Except(DST.Categorical)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b)
  @test Tables.getcolumn(n, :a) == t.a
  @test Tables.getcolumn(n, :b) == t.b
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Except(DST.Continuous)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:c, :d)
  @test Tables.getcolumn(n, :c) == t.c
  @test Tables.getcolumn(n, :d) == t.d
  tₒ = revert(T, n, c)
  @test t == tₒ
end

@testset "DropConstant" begin
  a = [4, 6, 7, 8, 1, 2]
  b = fill(5, 6)
  c = [1.9, 7.4, 8.6, 8.9, 2.4, 7.7]
  d = fill(5.5, 6)
  t = Table(; a, b, c, d)

  T = DropConstant()
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :c)
  @test Tables.getcolumn(n, :a) == t.a
  @test Tables.getcolumn(n, :c) == t.c
  tₒ = revert(T, n, c)
  @test t == tₒ
end

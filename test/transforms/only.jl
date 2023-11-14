@testset "Only" begin
  @test isrevertible(Only(DST.Continuous))

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

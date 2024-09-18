@testset "Map" begin
  @test !isrevertible(Map(row->row))
  a = [4, 7, 8, 5, 8, 1]
  b = [1, 9, 1, 7, 9, 4]
  c = [2, 8, 6, 3, 2, 2]
  d = [7, 5, 9, 5, 3, 4]
  t = Table(; a, b, c, d)

  T = Map((row -> row.a) => :e)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :e)
  @test n.e == t.a

  # error: cannot create Map transform without arguments
  @test_throws ArgumentError Map()
end

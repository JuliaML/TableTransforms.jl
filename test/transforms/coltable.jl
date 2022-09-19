@testset "ColTable" begin
  a = [3, 2, 1, 4, 5, 3]
  b = [1, 4, 4, 5, 8, 5]
  c = [1, 1, 6, 2, 4, 1]
  t = Table(; a, b, c)
  T = ColTable()
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  @test typeof(n) <: NamedTuple
  @test Tables.columnaccess(n)
  @test typeof(tₒ) <: Table
end

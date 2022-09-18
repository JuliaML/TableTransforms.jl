@testset "RowTable" begin
  a = [3, 2, 1, 4, 5, 3]
  b = [1, 4, 4, 5, 8, 5]
  c = [1, 1, 6, 2, 4, 1]
  t = Table(; a, b, c)
  T = RowTable()
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  @test typeof(n) <: Vector
  @test Tables.rowaccess(n)
  @test typeof(tₒ) <: Table
end

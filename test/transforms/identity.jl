@testset "Identity" begin
  x = rand(10)
  y = rand(10)
  t = Table(; x, y)
  T = Identity()
  n, c = apply(T, t)
  @test t == n
  tₒ = revert(T, n, c)
  @test t == tₒ

  # row table
  rt = Tables.rowtable(t)
  T = Identity()
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  rtₒ = revert(T, n, c)
  @test rt == rtₒ
end

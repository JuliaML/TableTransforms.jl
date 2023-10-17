@testset "LogRatio" begin
  @test isrevertible(ALR())
  @test isrevertible(CLR())
  @test isrevertible(ILR())

  a = [1.0, 0.0, 1.0]
  b = [2.0, 2.0, 2.0]
  c = [3.0, 3.0, 0.0]
  t = Table(; a, b, c)
  T = ALR()
  n, c = apply(T, t)
  @test n == t |> ALR(:c)
  talr = revert(T, n, c)
  T = CLR()
  n, c = apply(T, t)
  tclr = revert(T, n, c)
  T = ILR()
  n, c = apply(T, t)
  @test n == t |> ILR(:c)
  tilr = revert(T, n, c)
  @test Tables.matrix(talr) ≈ Tables.matrix(tclr)
  @test Tables.matrix(tclr) ≈ Tables.matrix(tilr)
  @test Tables.matrix(talr) ≈ Tables.matrix(tilr)
end

@testset "StdFeats" begin
  @test isrevertible(StdFeats())

  a = rand(1:10, 100)
  b = rand(Normal(7, 10), 100)
  c = rand('a':'z', 100)
  d = rand(Normal(15, 2), 100)
  e = rand(["y", "n"], 100)
  t = Table(; a, b, c, d, e)

  T = StdFeats()
  n, c = apply(T, t)
  @test n.a == t.a
  @test isapprox(mean(n.b), 0; atol=1e-6)
  @test isapprox(std(n.b), 1; atol=1e-6)
  @test n.c == t.c
  @test isapprox(mean(n.d), 0; atol=1e-6)
  @test isapprox(std(n.d), 1; atol=1e-6)
  @test n.e == t.e
  tₒ = revert(T, n, c)
  @test tₒ.a == t.a
  @test tₒ.b ≈ t.b
  @test tₒ.c == t.c
  @test tₒ.d ≈ t.d
  @test tₒ.e == t.e
end

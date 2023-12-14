@testset "Sample" begin
  @test !isrevertible(Sample(30))

  a = [3, 6, 2, 7, 8, 3]
  b = [8, 5, 1, 2, 3, 4]
  c = [1, 8, 5, 2, 9, 4]
  t = Table(; a, b, c)

  T = Sample(30, replace=true)
  n, c = apply(T, t)
  @test length(n.a) == 30

  T = Sample(6, replace=false)
  n, c = apply(T, t)
  @test n.a ⊆ t.a
  @test n.b ⊆ t.b
  @test n.c ⊆ t.c

  T = Sample(30, replace=true, ordered=true)
  n, c = apply(T, t)
  trows = Tables.rowtable(t)
  @test unique(Tables.rowtable(n)) == trows

  T = Sample(6, replace=false, ordered=true)
  n, c = apply(T, t)
  @test n.a ⊆ t.a
  @test n.b ⊆ t.b
  @test n.c ⊆ t.c
  @test Tables.rowtable(n) == trows

  T = Sample(8, replace=true, rng=MersenneTwister(2))
  n, c = apply(T, t)
  @test n.a == [3, 7, 8, 2, 2, 6, 2, 6]
  @test n.b == [8, 2, 3, 1, 1, 5, 1, 5]
  @test n.c == [1, 2, 9, 5, 5, 8, 5, 8]

  w = pweights([0.1, 0.25, 0.15, 0.25, 0.1, 0.15])
  T = Sample(10_000, w, replace=true, rng=MersenneTwister(2))
  n, c = apply(T, t)
  nrows = Tables.rowtable(n)
  @test isapprox(count(==(trows[1]), nrows) / 10_000, 0.10, atol=0.01)
  @test isapprox(count(==(trows[2]), nrows) / 10_000, 0.25, atol=0.01)
  @test isapprox(count(==(trows[3]), nrows) / 10_000, 0.15, atol=0.01)
  @test isapprox(count(==(trows[4]), nrows) / 10_000, 0.25, atol=0.01)
  @test isapprox(count(==(trows[5]), nrows) / 10_000, 0.10, atol=0.01)
  @test isapprox(count(==(trows[6]), nrows) / 10_000, 0.15, atol=0.01)

  w = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
  T = Sample(10_000, w, replace=true, rng=MersenneTwister(2))
  n, c = apply(T, t)
  nrows = Tables.rowtable(n)
  @test isapprox(count(==(trows[1]), nrows) / 10_000, 1 / 21, atol=0.01)
  @test isapprox(count(==(trows[2]), nrows) / 10_000, 2 / 21, atol=0.01)
  @test isapprox(count(==(trows[3]), nrows) / 10_000, 3 / 21, atol=0.01)
  @test isapprox(count(==(trows[4]), nrows) / 10_000, 4 / 21, atol=0.01)
  @test isapprox(count(==(trows[5]), nrows) / 10_000, 5 / 21, atol=0.01)
  @test isapprox(count(==(trows[6]), nrows) / 10_000, 6 / 21, atol=0.01)

  # performance tests
  trng = MersenneTwister(2) # test rng
  x = rand(trng, 100_000)
  y = rand(trng, 100_000)
  c = CoDaArray((a=rand(trng, 100_000), b=rand(trng, 100_000), c=rand(trng, 100_000)))
  t = (; x, y, c)

  T = Sample(10_000)
  @test @elapsed(apply(T, t)) < 0.5
end

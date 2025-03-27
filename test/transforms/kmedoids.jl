@testset "KMedoids" begin
  @test !isrevertible(KMedoids(3))
  @test TT.parameters(KMedoids(3)) == (k=3,)

  a = [randn(100); 10 .+ randn(100)]
  b = [randn(100); 10 .+ randn(100)]
  t = Table(; a, b)

  c = t |> KMedoids(2; rng)
  i1 = findall(isequal(1), c.cluster)
  i2 = findall(isequal(2), c.cluster)
  @test mean(t.a[i1]) > 5
  @test mean(t.b[i1]) > 5
  @test mean(t.a[i2]) < 5
  @test mean(t.b[i2]) < 5
end

@testset "KMedoids" begin
  @test !isrevertible(KMedoids(3))

  @test TT.parameters(KMedoids(3)) == (; k=3)

  # basic test with continuous variables
  a = [randn(100); 10 .+ randn(100)]
  b = [randn(100); 10 .+ randn(100)]
  t = Table(; a, b)
  n = t |> KMedoids(2; rng)
  i1 = findall(isequal(1), n.label)
  i2 = findall(isequal(2), n.label)
  @test mean(t.a[i1]) > 5
  @test mean(t.b[i1]) > 5
  @test mean(t.a[i2]) < 5
  @test mean(t.b[i2]) < 5

  # test with mixed variables
  a = [1, 2, 3]
  b = [1.0, 2.0, 3.0]
  c = ["a", "b", "c"]
  t = Table(; a, b, c)
  n = t |> KMedoids(3; rng)
  @test sort(n.label) == [1, 2, 3]
end

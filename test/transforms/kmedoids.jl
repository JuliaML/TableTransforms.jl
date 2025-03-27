@testset "KMedoids" begin
  @test !isrevertible(KMedoids(3))
  @test TT.parameters(KMedoids(3)) == (k=3,)
end

@testset "Distributions" begin
  values = randn(1000)
  d = TableTransforms.EmpiricalDistribution(values)
  @test 0.0 ≤ cdf(d, rand()) ≤ 1.0
  @test minimum(values) ≤ quantile(d, 0.5) ≤ maximum(values)
end

@testset "Assertions" begin
  a = rand(10)
  b = rand(10)
  c = rand(1:10, 10)
  d = rand(1:10, 10)
  e = categorical(rand(["y", "n"], 10))
  f = categorical(rand(["y", "n"], 10))
  table = Table(; a, b, c, d, e, f)

  selector = CS.selector([:a, :b])
  assertion = TT.SciTypeAssertion{Continuous}(selector)
  @test isnothing(assertion(table))
  selector = CS.selector([:a, :b, :c])
  assertion = TT.SciTypeAssertion{Continuous}(selector)
  @test_throws AssertionError assertion(table)

  selector = CS.selector([:c, :d])
  assertion = TT.SciTypeAssertion{Count}(selector)
  @test isnothing(assertion(table))
  selector = CS.selector([:c, :d, :e])
  assertion = TT.SciTypeAssertion{Count}(selector)
  @test_throws AssertionError assertion(table)

  selector = CS.selector([:e, :f])
  assertion = TT.SciTypeAssertion{Finite}(selector)
  @test isnothing(assertion(table))
  selector = CS.selector([:d, :e, :f])
  assertion = TT.SciTypeAssertion{Finite}(selector)
  @test_throws AssertionError assertion(table)
end

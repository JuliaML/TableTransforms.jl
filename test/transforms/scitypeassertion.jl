@testset "SciTypeAssertion" begin
  @test isrevertible(SciTypeAssertion(scitype=DST.Continuous))

  a = rand(10)
  b = rand(10)
  c = rand(1:10, 10)
  d = rand(1:10, 10)
  e = categorical(rand(["y", "n"], 10))
  f = categorical(rand(["y", "n"], 10))
  t = Table(; a, b, c, d, e, f)

  T = SciTypeAssertion(1, 2, scitype=DST.Continuous)
  n, c = apply(T, t)
  @test n == t
  tₒ = revert(T, n, c)
  @test tₒ == n == t
  T = SciTypeAssertion(1, 2, 3, scitype=DST.Continuous)
  @test_throws AssertionError apply(T, t)

  T = SciTypeAssertion([:c, :d], scitype=DST.Categorical)
  n, c = apply(T, t)
  @test n == t
  tₒ = revert(T, n, c)
  @test tₒ == n == t
  T = SciTypeAssertion([:a, :c, :d], scitype=DST.Categorical)
  @test_throws AssertionError apply(T, t)

  T = SciTypeAssertion(("e", "f"), scitype=DST.Categorical)
  n, c = apply(T, t)
  @test n == t
  tₒ = revert(T, n, c)
  @test tₒ == n == t
  T = SciTypeAssertion(("b", "e", "f"), scitype=DST.Categorical)
  @test_throws AssertionError apply(T, t)

  T = SciTypeAssertion(r"[ab]", scitype=DST.Continuous)
  n, c = apply(T, t)
  @test n == t
  tₒ = revert(T, n, c)
  @test tₒ == n == t
  T = SciTypeAssertion(r"[abc]", scitype=DST.Continuous)
  @test_throws AssertionError apply(T, t)
end

@testset "SciTypeAssertion" begin
  @test isrevertible(Assert(cond=allunique))

  a = [1, 2, 3, 4, 5, 6]
  b = [6, 5, 4, 3, 2, 1]
  c = [1, 2, 3, 4, 6, 6]
  d = [6, 6, 4, 3, 2, 1]
  t = Table(; a, b, c, d)

  T = Assert(1, 2, cond=allunique)
  n, c = apply(T, t)
  @test n == t
  tₒ = revert(T, n, c)
  @test tₒ == n == t
  T = Assert(1, 2, 3, cond=allunique)
  @test_throws AssertionError apply(T, t)

  T = Assert([:c, :d], cond=x -> sum(x) > 21)
  n, c = apply(T, t)
  @test n == t
  tₒ = revert(T, n, c)
  @test tₒ == n == t
  T = Assert([:b, :c, :d], cond=x -> sum(x) > 21)
  @test_throws AssertionError apply(T, t)

  T = Assert(("a", "b"), cond=allunique)
  n, c = apply(T, t)
  @test n == t
  tₒ = revert(T, n, c)
  @test tₒ == n == t
  T = Assert(("a", "b", "c"), cond=allunique, msg="assertion error")
  @test_throws AssertionError apply(T, t)
  @test_throws "assertion error" apply(T, t)

  T = Assert(r"[cd]", cond=x -> sum(x) > 21)
  n, c = apply(T, t)
  @test n == t
  tₒ = revert(T, n, c)
  @test tₒ == n == t
  T = Assert(r"[bcd]", cond=x -> sum(x) > 21, msg=nm -> "error in column $nm")
  @test_throws AssertionError apply(T, t)
  @test_throws "error in column b" apply(T, t)
end

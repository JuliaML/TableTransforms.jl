@testset "AbsoluteUnits" begin
  @test isrevertible(AbsoluteUnits())

  a = [7, 4, 4, 7, 4, 1, 1, 6, 4, 7] * u"°C"
  b = [4, 5, 4, missing, 6, 6, missing, 4, 4, 1] * u"K"
  c = [3.9, 3.8, 3.5, 6.5, 7.7, 1.5, 0.6, 5.7, 4.7, 4.8] * u"K"
  d = [6.3, 4.7, 7.6, missing, 1.2, missing, 5.9, 0.2, 1.9, 4.2] * u"°C"
  e = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
  t = Table(; a, b, c, d, e)

  T = AbsoluteUnits()
  n, c = apply(T, t)
  @test unit(eltype(n.a)) === u"K"
  @test unit(nonmissingtype(eltype(n.b))) === u"K"
  @test unit(eltype(n.c)) === u"K"
  @test unit(nonmissingtype(eltype(n.d))) === u"K"
  @test eltype(n.e) === String
  @test n.e == t.e
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test all(isapprox.(skipmissing(t.d), skipmissing(tₒ.d)))
  @test t.e == tₒ.e

  # args...
  # integers
  T = AbsoluteUnits(1, 2)
  n, c = apply(T, t)
  @test unit(eltype(n.a)) === u"K"
  @test unit(nonmissingtype(eltype(n.b))) === u"K"
  @test unit(eltype(n.c)) === u"K"
  @test unit(nonmissingtype(eltype(n.d))) === u"°C"
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e

  # symbols
  T = AbsoluteUnits(:a, :b)
  n, c = apply(T, t)
  @test unit(eltype(n.a)) === u"K"
  @test unit(nonmissingtype(eltype(n.b))) === u"K"
  @test unit(eltype(n.c)) === u"K"
  @test unit(nonmissingtype(eltype(n.d))) === u"°C"
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e

  # strings
  T = AbsoluteUnits("a", "b")
  n, c = apply(T, t)
  @test unit(eltype(n.a)) === u"K"
  @test unit(nonmissingtype(eltype(n.b))) === u"K"
  @test unit(eltype(n.c)) === u"K"
  @test unit(nonmissingtype(eltype(n.d))) === u"°C"
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e

  # vector
  # integers
  T = AbsoluteUnits([3, 4])
  n, c = apply(T, t)
  @test unit(eltype(n.a)) === u"°C"
  @test unit(nonmissingtype(eltype(n.b))) === u"K"
  @test unit(eltype(n.c)) === u"K"
  @test unit(nonmissingtype(eltype(n.d))) === u"K"
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test all(isapprox.(skipmissing(t.d), skipmissing(tₒ.d)))
  @test t.e == tₒ.e

  # symbols
  T = AbsoluteUnits([:c, :d])
  n, c = apply(T, t)
  @test unit(eltype(n.a)) === u"°C"
  @test unit(nonmissingtype(eltype(n.b))) === u"K"
  @test unit(eltype(n.c)) === u"K"
  @test unit(nonmissingtype(eltype(n.d))) === u"K"
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test all(isapprox.(skipmissing(t.d), skipmissing(tₒ.d)))
  @test t.e == tₒ.e

  # strings
  T = AbsoluteUnits(["c", "d"])
  n, c = apply(T, t)
  @test unit(eltype(n.a)) === u"°C"
  @test unit(nonmissingtype(eltype(n.b))) === u"K"
  @test unit(eltype(n.c)) === u"K"
  @test unit(nonmissingtype(eltype(n.d))) === u"K"
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test all(isapprox.(skipmissing(t.d), skipmissing(tₒ.d)))
  @test t.e == tₒ.e

  # tuple
  # integers
  T = AbsoluteUnits((1, 4, 5))
  n, c = apply(T, t)
  @test unit(eltype(n.a)) === u"K"
  @test unit(nonmissingtype(eltype(n.b))) === u"K"
  @test unit(eltype(n.c)) === u"K"
  @test unit(nonmissingtype(eltype(n.d))) === u"K"
  @test eltype(n.e) === String
  @test n.e == t.e
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test all(isapprox.(skipmissing(t.d), skipmissing(tₒ.d)))
  @test t.e == tₒ.e

  # symbols
  T = AbsoluteUnits((:a, :d, :e))
  n, c = apply(T, t)
  @test unit(eltype(n.a)) === u"K"
  @test unit(nonmissingtype(eltype(n.b))) === u"K"
  @test unit(eltype(n.c)) === u"K"
  @test unit(nonmissingtype(eltype(n.d))) === u"K"
  @test eltype(n.e) === String
  @test n.e == t.e
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test all(isapprox.(skipmissing(t.d), skipmissing(tₒ.d)))
  @test t.e == tₒ.e

  # strings
  T = AbsoluteUnits(("a", "d", "e"))
  n, c = apply(T, t)
  @test unit(eltype(n.a)) === u"K"
  @test unit(nonmissingtype(eltype(n.b))) === u"K"
  @test unit(eltype(n.c)) === u"K"
  @test unit(nonmissingtype(eltype(n.d))) === u"K"
  @test eltype(n.e) === String
  @test n.e == t.e
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test all(isapprox.(skipmissing(t.d), skipmissing(tₒ.d)))
  @test t.e == tₒ.e

  # regex
  T = AbsoluteUnits(r"[ade]")
  n, c = apply(T, t)
  @test unit(eltype(n.a)) === u"K"
  @test unit(nonmissingtype(eltype(n.b))) === u"K"
  @test unit(eltype(n.c)) === u"K"
  @test unit(nonmissingtype(eltype(n.d))) === u"K"
  @test eltype(n.e) === String
  @test n.e == t.e
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test all(isapprox.(skipmissing(t.d), skipmissing(tₒ.d)))
  @test t.e == tₒ.e
end

@testset "DropUnits" begin
  @test isrevertible(DropUnits())

  a = [7, 4, 4, 7, 4, 1, 1, 6, 4, 7] * u"m/s"
  b = [4, 5, 4, missing, 6, 6, missing, 4, 4, 1] * u"m^2"
  c = [3.9, 3.8, 3.5, 6.5, 7.7, 1.5, 0.6, 5.7, 4.7, 4.8] * u"km/hr"
  d = [6.3, 4.7, 7.6, missing, 1.2, missing, 5.9, 0.2, 1.9, 4.2] * u"km^2"
  e = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
  t = Table(; a, b, c, d, e)

  T = DropUnits()
  n, c = apply(T, t)
  @test eltype(n.a) === Int
  @test unit(eltype(n.a)) === NoUnits
  @test nonmissingtype(eltype(n.b)) === Int
  @test unit(nonmissingtype(eltype(n.b))) === NoUnits
  @test eltype(n.c) === Float64
  @test unit(eltype(n.c)) === NoUnits
  @test nonmissingtype(eltype(n.d)) === Float64
  @test unit(nonmissingtype(eltype(n.d))) === NoUnits
  @test eltype(n.e) === String
  @test n.e == t.e
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e

  # args...
  # integers
  T = DropUnits(1, 2)
  n, c = apply(T, t)
  @test eltype(n.a) === Int
  @test unit(eltype(n.a)) === NoUnits
  @test nonmissingtype(eltype(n.b)) === Int
  @test unit(nonmissingtype(eltype(n.b))) === NoUnits
  @test unit(eltype(n.c)) === u"km/hr"
  @test unit(nonmissingtype(eltype(n.d))) === u"km^2"
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e

  # symbols
  T = DropUnits(:a, :b)
  n, c = apply(T, t)
  @test eltype(n.a) === Int
  @test unit(eltype(n.a)) === NoUnits
  @test nonmissingtype(eltype(n.b)) === Int
  @test unit(nonmissingtype(eltype(n.b))) === NoUnits
  @test unit(eltype(n.c)) === u"km/hr"
  @test unit(nonmissingtype(eltype(n.d))) === u"km^2"
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e

  # strings
  T = DropUnits("a", "b")
  n, c = apply(T, t)
  @test eltype(n.a) === Int
  @test unit(eltype(n.a)) === NoUnits
  @test nonmissingtype(eltype(n.b)) === Int
  @test unit(nonmissingtype(eltype(n.b))) === NoUnits
  @test unit(eltype(n.c)) === u"km/hr"
  @test unit(nonmissingtype(eltype(n.d))) === u"km^2"
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e

  # vector
  # integers
  T = DropUnits([3, 4])
  n, c = apply(T, t)
  @test unit(eltype(n.a)) === u"m/s"
  @test unit(nonmissingtype(eltype(n.b))) === u"m^2"
  @test eltype(n.c) === Float64
  @test unit(eltype(n.c)) === NoUnits
  @test nonmissingtype(eltype(n.d)) === Float64
  @test unit(nonmissingtype(eltype(n.d))) === NoUnits
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e

  # symbols
  T = DropUnits([:c, :d])
  n, c = apply(T, t)
  @test unit(eltype(n.a)) === u"m/s"
  @test unit(nonmissingtype(eltype(n.b))) === u"m^2"
  @test eltype(n.c) === Float64
  @test unit(eltype(n.c)) === NoUnits
  @test nonmissingtype(eltype(n.d)) === Float64
  @test unit(nonmissingtype(eltype(n.d))) === NoUnits
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e

  # strings
  T = DropUnits(["c", "d"])
  n, c = apply(T, t)
  @test unit(eltype(n.a)) === u"m/s"
  @test unit(nonmissingtype(eltype(n.b))) === u"m^2"
  @test eltype(n.c) === Float64
  @test unit(eltype(n.c)) === NoUnits
  @test nonmissingtype(eltype(n.d)) === Float64
  @test unit(nonmissingtype(eltype(n.d))) === NoUnits
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e

  # tuple
  # integers
  T = DropUnits((2, 4, 5))
  n, c = apply(T, t)
  @test unit(eltype(n.a)) === u"m/s"
  @test nonmissingtype(eltype(n.b)) === Int
  @test unit(nonmissingtype(eltype(n.b))) === NoUnits
  @test unit(eltype(n.c)) === u"km/hr"
  @test nonmissingtype(eltype(n.d)) === Float64
  @test unit(nonmissingtype(eltype(n.d))) === NoUnits
  @test eltype(n.e) === String
  @test n.e == t.e
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e

  # symbols
  T = DropUnits((:b, :d, :e))
  n, c = apply(T, t)
  @test unit(eltype(n.a)) === u"m/s"
  @test nonmissingtype(eltype(n.b)) === Int
  @test unit(nonmissingtype(eltype(n.b))) === NoUnits
  @test unit(eltype(n.c)) === u"km/hr"
  @test nonmissingtype(eltype(n.d)) === Float64
  @test unit(nonmissingtype(eltype(n.d))) === NoUnits
  @test eltype(n.e) === String
  @test n.e == t.e
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e

  # strings
  T = DropUnits(("b", "d", "e"))
  n, c = apply(T, t)
  @test unit(eltype(n.a)) === u"m/s"
  @test nonmissingtype(eltype(n.b)) === Int
  @test unit(nonmissingtype(eltype(n.b))) === NoUnits
  @test unit(eltype(n.c)) === u"km/hr"
  @test nonmissingtype(eltype(n.d)) === Float64
  @test unit(nonmissingtype(eltype(n.d))) === NoUnits
  @test eltype(n.e) === String
  @test n.e == t.e
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e

  # regex
  T = DropUnits(r"[ace]")
  n, c = apply(T, t)
  @test eltype(n.a) === Int
  @test unit(eltype(n.a)) === NoUnits
  @test unit(nonmissingtype(eltype(n.b))) === u"m^2"
  @test eltype(n.c) === Float64
  @test unit(eltype(n.c)) === NoUnits
  @test unit(nonmissingtype(eltype(n.d))) === u"km^2"
  @test n.e == t.e
  @test eltype(n.e) === String
  tₒ = revert(T, n, c)
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e
end

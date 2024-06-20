@testset "Unit" begin
  @test isrevertible(Unit(u"m"))

  a = [2.7, 2.9, 2.2, 1.4, 1.8, 3.3] * u"m"
  b = [300, 500, missing, 800, missing, 400] * u"cm"
  c = [8, 2, 5, 7, 9, 4] * u"km"
  d = [0.3, 0.1, 0.9, 0.2, 0.7, 0.4]
  e = ["no", "no", "yes", "yes", "no", "yes"]
  t = Table(; a, b, c, d, e)

  T = Unit(u"m")
  n, c = apply(T, t)
  @test unit(eltype(n.a)) == u"m"
  @test unit(eltype(n.b)) == u"m"
  @test unit(eltype(n.c)) == u"m"
  @test eltype(n.d) <: Float64
  @test eltype(n.e) <: String
  tₒ = revert(T, n, c)
  @test unit(eltype(tₒ.a)) == u"m"
  @test unit(eltype(tₒ.b)) == u"cm"
  @test unit(eltype(tₒ.c)) == u"km"
  @test all(isapprox.(t.a, tₒ.a))
  @test all(isapprox.(skipmissing(t.b), skipmissing(tₒ.b)))
  @test all(isapprox.(t.c, tₒ.c))
  @test t.d == tₒ.d
  @test t.e == tₒ.e

  a = [2.7, 2.9, 2.2, 1.4, 1.8, 3.3] * u"m"
  b = [300, 500, missing, 800, missing, 400] * u"cm"
  c = [8, 2, 5, 7, 9, 4] * u"km"
  d = [29.1, missing, 29.2, missing, 28.4, 26.4] * u"°C"
  e = [0.9, 0.4, 0.5, 0.1, 0.3, 0.6] * u"kg"
  f = 0.5u"ppm" * e
  t = Table(; a, b, c, d, e, f)

  T = Unit(4 => u"K")
  n, c = apply(T, t)
  @test unit(eltype(n.a)) == u"m"
  @test unit(eltype(n.b)) == u"cm"
  @test unit(eltype(n.c)) == u"km"
  @test unit(eltype(n.d)) == u"K"
  @test unit(eltype(n.e)) == u"kg"
  @test unit(eltype(n.f)) == u"kg * ppm"
  tₒ = revert(T, n, c)
  @test unit(eltype(tₒ.d)) == u"°C"
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test all(isapprox.(skipmissing(t.d), skipmissing(tₒ.d)))
  @test t.e == tₒ.e
  @test t.f == tₒ.f

  T = Unit(:e => u"g")
  n, c = apply(T, t)
  @test unit(eltype(n.a)) == u"m"
  @test unit(eltype(n.b)) == u"cm"
  @test unit(eltype(n.c)) == u"km"
  @test unit(eltype(n.d)) == u"°C"
  @test unit(eltype(n.e)) == u"g"
  @test unit(eltype(n.f)) == u"kg * ppm"
  tₒ = revert(T, n, c)
  @test unit(eltype(tₒ.e)) == u"kg"
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test isequal(t.d, tₒ.d)
  @test all(isapprox.(t.e, tₒ.e))
  @test t.f == tₒ.f

  T = Unit("f" => u"kg")
  n, c = apply(T, t)
  @test unit(eltype(n.a)) == u"m"
  @test unit(eltype(n.b)) == u"cm"
  @test unit(eltype(n.c)) == u"km"
  @test unit(eltype(n.d)) == u"°C"
  @test unit(eltype(n.e)) == u"kg"
  @test unit(eltype(n.f)) == u"kg"
  tₒ = revert(T, n, c)
  @test unit(eltype(tₒ.f)) == u"kg * ppm"
  @test t.a == tₒ.a
  @test isequal(t.b, tₒ.b)
  @test t.c == tₒ.c
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e
  @test all(isapprox.(t.f, tₒ.f))

  T = Unit([1, 2, 3] => u"m")
  n, c = apply(T, t)
  @test unit(eltype(n.a)) == u"m"
  @test unit(eltype(n.b)) == u"m"
  @test unit(eltype(n.c)) == u"m"
  @test unit(eltype(n.d)) == u"°C"
  @test unit(eltype(n.e)) == u"kg"
  @test unit(eltype(n.f)) == u"kg * ppm"
  tₒ = revert(T, n, c)
  @test unit(eltype(tₒ.a)) == u"m"
  @test unit(eltype(tₒ.b)) == u"cm"
  @test unit(eltype(tₒ.c)) == u"km"
  @test all(isapprox.(t.a, tₒ.a))
  @test all(isapprox.(skipmissing(t.b), skipmissing(tₒ.b)))
  @test all(isapprox.(t.c, tₒ.c))
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e
  @test t.f == tₒ.f

  T = Unit([:a, :b, :c] => u"cm")
  n, c = apply(T, t)
  @test unit(eltype(n.a)) == u"cm"
  @test unit(eltype(n.b)) == u"cm"
  @test unit(eltype(n.c)) == u"cm"
  @test unit(eltype(n.d)) == u"°C"
  @test unit(eltype(n.e)) == u"kg"
  @test unit(eltype(n.f)) == u"kg * ppm"
  tₒ = revert(T, n, c)
  @test unit(eltype(tₒ.a)) == u"m"
  @test unit(eltype(tₒ.b)) == u"cm"
  @test unit(eltype(tₒ.c)) == u"km"
  @test all(isapprox.(t.a, tₒ.a))
  @test all(isapprox.(skipmissing(t.b), skipmissing(tₒ.b)))
  @test all(isapprox.(t.c, tₒ.c))
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e
  @test t.f == tₒ.f

  T = Unit(["a", "b", "c"] => u"km")
  n, c = apply(T, t)
  @test unit(eltype(n.a)) == u"km"
  @test unit(eltype(n.b)) == u"km"
  @test unit(eltype(n.c)) == u"km"
  @test unit(eltype(n.d)) == u"°C"
  @test unit(eltype(n.e)) == u"kg"
  @test unit(eltype(n.f)) == u"kg * ppm"
  tₒ = revert(T, n, c)
  @test unit(eltype(tₒ.a)) == u"m"
  @test unit(eltype(tₒ.b)) == u"cm"
  @test unit(eltype(tₒ.c)) == u"km"
  @test all(isapprox.(t.a, tₒ.a))
  @test all(isapprox.(skipmissing(t.b), skipmissing(tₒ.b)))
  @test all(isapprox.(t.c, tₒ.c))
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e
  @test t.f == tₒ.f

  T = Unit(r"[abc]" => u"m")
  n, c = apply(T, t)
  @test unit(eltype(n.a)) == u"m"
  @test unit(eltype(n.b)) == u"m"
  @test unit(eltype(n.c)) == u"m"
  @test unit(eltype(n.d)) == u"°C"
  @test unit(eltype(n.e)) == u"kg"
  @test unit(eltype(n.f)) == u"kg * ppm"
  tₒ = revert(T, n, c)
  @test unit(eltype(tₒ.a)) == u"m"
  @test unit(eltype(tₒ.b)) == u"cm"
  @test unit(eltype(tₒ.c)) == u"km"
  @test all(isapprox.(t.a, tₒ.a))
  @test all(isapprox.(skipmissing(t.b), skipmissing(tₒ.b)))
  @test all(isapprox.(t.c, tₒ.c))
  @test isequal(t.d, tₒ.d)
  @test t.e == tₒ.e
  @test t.f == tₒ.f

  # error: cannot create Unit transform without arguments
  @test_throws ArgumentError Unit()
end

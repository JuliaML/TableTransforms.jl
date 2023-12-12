@testset "Unitify" begin
  @test isrevertible(Unitify())

  anm = Symbol("a [m]")
  bnm = :b
  cnm = Symbol("c [km/hr]")
  dnm = :d
  enm = Symbol("e [°C]")
  a = rand(10)
  b = rand(10)
  c = rand(10)
  d = rand(10)
  e = rand(10)
  t = Table(; anm => a, bnm => b, cnm => c, dnm => d, enm => e)

  T = Unitify()
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :b, :c, :d, :e)
  @test unit(eltype(n.a)) === u"m"
  @test unit(eltype(n.b)) === NoUnits
  @test unit(eltype(n.c)) === u"km/hr"
  @test unit(eltype(n.d)) === NoUnits
  @test unit(eltype(n.e)) === u"°C"
  tₒ = revert(T, n, c)
  @test tₒ == t

  # invalid unit name
  t = Table(; Symbol("a [test]") => rand(10))
  T = Unitify()
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a,)
  @test unit(eltype(n.a)) === NoUnits
  tₒ = revert(T, n, c)
  @test tₒ == t
end

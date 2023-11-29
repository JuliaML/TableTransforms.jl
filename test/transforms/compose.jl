@testset "Compose" begin
  @test isrevertible(Compose())

  a = rand(10)
  b = rand(10)
  c = rand(10)
  t = Table(; a, b, c)

  T = Compose()
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:CODA,)
  @test n.CODA isa CoDaArray
  @test n.CODA == CoDaArray(t)
  tₒ = revert(T, n, c)
  @test tₒ == t

  T = Compose(as=:comp)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:comp,)
  @test n.comp isa CoDaArray
  @test n.comp == CoDaArray(t)
  tₒ = revert(T, n, c)
  @test tₒ == t

  T = Compose(1, 2)
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:c, :CODA)
  @test n.CODA isa CoDaArray
  @test n.CODA == CoDaArray((a=t.a, b=t.b))
  tₒ = revert(T, n, c)
  @test tₒ == t

  T = Compose([:a, :c])
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:b, :CODA)
  @test n.CODA isa CoDaArray
  @test n.CODA == CoDaArray((a=t.a, c=t.c))
  tₒ = revert(T, n, c)
  @test tₒ == t

  T = Compose(("b", "c"))
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:a, :CODA)
  @test n.CODA isa CoDaArray
  @test n.CODA == CoDaArray((b=t.b, c=t.c))
  tₒ = revert(T, n, c)
  @test tₒ == t

  T = Compose(r"[ab]", as="COMP")
  n, c = apply(T, t)
  @test Tables.schema(n).names == (:c, :COMP)
  @test n.COMP isa CoDaArray
  @test n.COMP == CoDaArray((a=t.a, b=t.b))
  tₒ = revert(T, n, c)
  @test tₒ == t
end

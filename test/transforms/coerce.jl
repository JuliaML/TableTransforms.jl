@testset "Coerce" begin
  a = [1, 2, 3, 4, 5]
  b = [1.0, 2.0, 3.0, 4.0, 5.0]
  t = Table(; a, b)

  T = Coerce(1 => DST.Continuous, 2 => DST.Categorical)
  n, c = apply(T, t)
  @test eltype(n.a) <: Float64
  @test eltype(n.b) <: Int
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  @test eltype(tₒ.a) == eltype(t.a)
  @test eltype(tₒ.b) == eltype(t.b)

  T = Coerce(:a => DST.Continuous, :b => DST.Categorical)
  n, c = apply(T, t)
  @test eltype(n.a) <: Float64
  @test eltype(n.b) <: Int
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  @test eltype(tₒ.a) == eltype(t.a)
  @test eltype(tₒ.b) == eltype(t.b)

  T = Coerce("a" => DST.Continuous, "b" => DST.Categorical)
  n, c = apply(T, t)
  @test eltype(n.a) <: Float64
  @test eltype(n.b) <: Int
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  @test eltype(tₒ.a) == eltype(t.a)
  @test eltype(tₒ.b) == eltype(t.b)

  T = Coerce(DST.Continuous)
  n, c = apply(T, t)
  @test eltype(n.a) <: Float64
  @test eltype(n.b) <: Float64
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  @test eltype(tₒ.a) == eltype(t.a)
  @test eltype(tₒ.b) == eltype(t.b)

  T = Coerce(DST.Categorical)
  n, c = apply(T, t)
  @test eltype(n.a) <: Int
  @test eltype(n.b) <: Int
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  @test eltype(tₒ.a) == eltype(t.a)
  @test eltype(tₒ.b) == eltype(t.b)

  # row table
  rt = Tables.rowtable(t)
  T = Coerce(:a => DST.Continuous, :b => DST.Categorical)
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  rtₒ = revert(T, n, c)
  @test rt == rtₒ

  # error: cannot create Coerce transform without arguments
  @test_throws ArgumentError Coerce()
end

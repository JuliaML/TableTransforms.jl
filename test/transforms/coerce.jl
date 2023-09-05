@testset "Coerce" begin
  x1 = [1.0, 2.0, 3.0, 4.0, 5.0]
  x2 = [1.0, 2.0, 3.0, 4.0, 5.0]
  x3 = [5.0, 5.0, 5.0, 5.0, 5.0]
  t = Table(; x1, x2, x3)

  T = Coerce(:x1 => Count, :x2 => Count)
  n, c = apply(T, t)
  @test eltype(n.x1) == Int
  @test eltype(n.x2) == Int
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  @test eltype(tₒ.x1) == eltype(t.x1)
  @test eltype(tₒ.x2) == eltype(t.x2)

  T = Coerce(:x1 => Multiclass, :x2 => Multiclass)
  n, c = apply(T, t)
  @test eltype(n.x1) <: CategoricalValue
  @test eltype(n.x2) <: CategoricalValue
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  @test eltype(tₒ.x1) == eltype(t.x1)
  @test eltype(tₒ.x2) == eltype(t.x2)

  T = Coerce("x1" => Multiclass, "x2" => Multiclass)
  n, c = apply(T, t)
  @test eltype(n.x1) <: CategoricalValue
  @test eltype(n.x2) <: CategoricalValue
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  @test eltype(tₒ.x1) == eltype(t.x1)
  @test eltype(tₒ.x2) == eltype(t.x2)

  # row table
  rt = Tables.rowtable(t)
  T = Coerce(:x1 => Count, :x2 => Count)
  n, c = apply(T, rt)
  @test Tables.isrowtable(n)
  rtₒ = revert(T, n, c)
  @test rt == rtₒ
end

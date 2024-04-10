@testset "DropNaN" begin
  @test !isrevertible(DropNaN())

  a = [1.8, 0.5, 1.2, 3.7, 5.0, NaN]
  b = [6.0f0, 5.4f0, 5.4f0, NaN32, 5.5f0, 2.6f0]
  c = [4.9, 5.1, NaN, 5.1, 8.6, 4.4] * u"m"
  d = [NaN32, 1.0f0, 8.8f0, 0.1f0, 1.5f0, 9.5f0] * u"m"
  e = ["yes", "no", "no", "yes", "yes", "no"]
  t = Table(; a, b, c, d, e)

  T = DropNaN()
  n, c = apply(T, t)
  @test n.a == [0.5, 5.0]
  @test n.b == [5.4f0, 5.5f0]
  @test n.c == [5.1, 8.6] * u"m"
  @test n.d == [1.0f0, 1.5f0] * u"m"
  @test n.e == ["no", "yes"]

  # args...
  # integers
  T = DropNaN(1, 3)
  n, c = apply(T, t)
  @test isequal(n.a, [1.8, 0.5, 3.7, 5.0])
  @test isequal(n.b, [6.0f0, 5.4f0, NaN32, 5.5f0])
  @test isequal(n.c, [4.9, 5.1, 5.1, 8.6] * u"m")
  @test isequal(n.d, [NaN32, 1.0f0, 0.1f0, 1.5f0] * u"m")
  @test isequal(n.e, ["yes", "no", "yes", "yes"])

  # symbols
  T = DropNaN(:a, :c)
  n, c = apply(T, t)
  @test isequal(n.a, [1.8, 0.5, 3.7, 5.0])
  @test isequal(n.b, [6.0f0, 5.4f0, NaN32, 5.5f0])
  @test isequal(n.c, [4.9, 5.1, 5.1, 8.6] * u"m")
  @test isequal(n.d, [NaN32, 1.0f0, 0.1f0, 1.5f0] * u"m")
  @test isequal(n.e, ["yes", "no", "yes", "yes"])

  # strings
  T = DropNaN("a", "c")
  n, c = apply(T, t)
  @test isequal(n.a, [1.8, 0.5, 3.7, 5.0])
  @test isequal(n.b, [6.0f0, 5.4f0, NaN32, 5.5f0])
  @test isequal(n.c, [4.9, 5.1, 5.1, 8.6] * u"m")
  @test isequal(n.d, [NaN32, 1.0f0, 0.1f0, 1.5f0] * u"m")
  @test isequal(n.e, ["yes", "no", "yes", "yes"])

  # vector
  # integers
  T = DropNaN([2, 4])
  n, c = apply(T, t)
  @test isequal(n.a, [0.5, 1.2, 5.0, NaN])
  @test isequal(n.b, [5.4f0, 5.4f0, 5.5f0, 2.6f0])
  @test isequal(n.c, [5.1, NaN, 8.6, 4.4] * u"m")
  @test isequal(n.d, [1.0f0, 8.8f0, 1.5f0, 9.5f0] * u"m")
  @test isequal(n.e, ["no", "no", "yes", "no"])

  # symbols
  T = DropNaN([:b, :d])
  n, c = apply(T, t)
  @test isequal(n.a, [0.5, 1.2, 5.0, NaN])
  @test isequal(n.b, [5.4f0, 5.4f0, 5.5f0, 2.6f0])
  @test isequal(n.c, [5.1, NaN, 8.6, 4.4] * u"m")
  @test isequal(n.d, [1.0f0, 8.8f0, 1.5f0, 9.5f0] * u"m")
  @test isequal(n.e, ["no", "no", "yes", "no"])

  # strings
  T = DropNaN(["b", "d"])
  n, c = apply(T, t)
  @test isequal(n.a, [0.5, 1.2, 5.0, NaN])
  @test isequal(n.b, [5.4f0, 5.4f0, 5.5f0, 2.6f0])
  @test isequal(n.c, [5.1, NaN, 8.6, 4.4] * u"m")
  @test isequal(n.d, [1.0f0, 8.8f0, 1.5f0, 9.5f0] * u"m")
  @test isequal(n.e, ["no", "no", "yes", "no"])

  # tuple
  # integers
  T = DropNaN((1, 2, 3))
  n, c = apply(T, t)
  @test isequal(n.a, [1.8, 0.5, 5.0])
  @test isequal(n.b, [6.0f0, 5.4f0, 5.5f0])
  @test isequal(n.c, [4.9, 5.1, 8.6] * u"m")
  @test isequal(n.d, [NaN32, 1.0f0, 1.5f0] * u"m")
  @test isequal(n.e, ["yes", "no", "yes"])

  # symbols
  T = DropNaN((:a, :b, :c))
  n, c = apply(T, t)
  @test isequal(n.a, [1.8, 0.5, 5.0])
  @test isequal(n.b, [6.0f0, 5.4f0, 5.5f0])
  @test isequal(n.c, [4.9, 5.1, 8.6] * u"m")
  @test isequal(n.d, [NaN32, 1.0f0, 1.5f0] * u"m")
  @test isequal(n.e, ["yes", "no", "yes"])

  # strings
  T = DropNaN(("a", "b", "c"))
  n, c = apply(T, t)
  @test isequal(n.a, [1.8, 0.5, 5.0])
  @test isequal(n.b, [6.0f0, 5.4f0, 5.5f0])
  @test isequal(n.c, [4.9, 5.1, 8.6] * u"m")
  @test isequal(n.d, [NaN32, 1.0f0, 1.5f0] * u"m")
  @test isequal(n.e, ["yes", "no", "yes"])

  # regex
  T = DropNaN(r"[bcd]")
  n, c = apply(T, t)
  @test isequal(n.a, [0.5, 5.0, NaN])
  @test isequal(n.b, [5.4f0, 5.5f0, 2.6f0])
  @test isequal(n.c, [5.1, 8.6, 4.4] * u"m")
  @test isequal(n.d, [1.0f0, 1.5f0, 9.5f0] * u"m")
  @test isequal(n.e, ["no", "yes", "no"])
end

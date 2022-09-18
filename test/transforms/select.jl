@testset "Select" begin
  a = rand(4000)
  b = rand(4000)
  c = rand(4000)
  d = rand(4000)
  e = rand(4000)
  f = rand(4000)
  t = Table(; a, b, c, d, e, f)

  T = Select(:f, :d)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:f, :d]
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Select(:f, :d, :b)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:f, :d, :b]
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Select(:d, :c, :b)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:d, :c, :b]
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Select(:e, :c, :b, :a)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:e, :c, :b, :a]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # selection with tuples
  T = Select((:e, :c, :b, :a))
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:e, :c, :b, :a]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # selection with vectors
  T = Select([:e, :c, :b, :a])
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:e, :c, :b, :a]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # selection with strings
  T = Select("d", "c", "b")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:d, :c, :b]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # selection with tuple of strings
  T = Select(("d", "c", "b"))
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:d, :c, :b]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # selection with vector of strings
  T = Select(["d", "c", "b"])
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:d, :c, :b]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # selection with integers
  T = Select(4, 3, 2)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:d, :c, :b]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # selection with tuple of integers
  T = Select((4, 3, 2))
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:d, :c, :b]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # selection with vector of integers
  T = Select([4, 3, 2])
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:d, :c, :b]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # reapply test
  T = Select(:b, :c, :d)
  n1, c1 = apply(T, t)
  n2 = reapply(T, t, c1)
  @test n1 == n2

  # selection with renaming
  a = rand(4000)
  b = rand(4000)
  c = rand(4000)
  d = rand(4000)
  t = Table(; a, b, c, d)

  # integer => symbol
  T = Select(1 => :x, 3 => :y)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:x, :y]
  @test Tables.getcolumn(n, :x) == t.a
  @test Tables.getcolumn(n, :y) == t.c

  # integer => string
  T = Select(2 => "x", 4 => "y")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:x, :y]
  @test Tables.getcolumn(n, :x) == t.b
  @test Tables.getcolumn(n, :y) == t.d

  # symbol => symbol
  T = Select(:a => :x, :c => :y)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:x, :y]
  @test Tables.getcolumn(n, :x) == t.a
  @test Tables.getcolumn(n, :y) == t.c

  # symbol => string
  T = Select(:b => "x", :d => "y")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:x, :y]
  @test Tables.getcolumn(n, :x) == t.b
  @test Tables.getcolumn(n, :y) == t.d

  T = Select(:a => :x1, :b => :x2, :c => :x3, :d => :x4)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:x1, :x2, :x3, :x4]
  @test Tables.getcolumn(n, :x1) == t.a
  @test Tables.getcolumn(n, :x2) == t.b
  @test Tables.getcolumn(n, :x3) == t.c
  @test Tables.getcolumn(n, :x4) == t.d

  # string => symbol
  T = Select("a" => :x, "c" => :y)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:x, :y]
  @test Tables.getcolumn(n, :x) == t.a
  @test Tables.getcolumn(n, :y) == t.c

  # string => string
  T = Select("b" => "x", "d" => "y")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:x, :y]
  @test Tables.getcolumn(n, :x) == t.b
  @test Tables.getcolumn(n, :y) == t.d

  T = Select("a" => "x1", "b" => "x2", "c" => "x3", "d" => "x4")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:x1, :x2, :x3, :x4]
  @test Tables.getcolumn(n, :x1) == t.a
  @test Tables.getcolumn(n, :x2) == t.b
  @test Tables.getcolumn(n, :x3) == t.c
  @test Tables.getcolumn(n, :x4) == t.d

  # row table
  rt = Tables.rowtable(t)
  cols = Tables.columns(rt)

  T = Select(:a => :x, :c => :y)
  n, c = apply(T, rt)
  @test Tables.columnnames(n) == [:x, :y]
  @test Tables.getcolumn(n, :x) == Tables.getcolumn(cols, :a)
  @test Tables.getcolumn(n, :y) == Tables.getcolumn(cols, :c)
  rtₒ = revert(T, n, c)
  @test rt == rtₒ

  # reapply test
  T = Select(:b => :x, :d => :y)
  n1, c1 = apply(T, t)
  n2 = reapply(T, t, c1)
  @test n1 == n2

  # selection with Regex
  T = Select(r"[dcb]")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:b, :c, :d] # the order of columns is preserved
  tₒ = revert(T, n, c)
  @test t == tₒ

  # different columntypes
  t = (a = rand(3), b = rand(ComplexF64, 3))
  T = Select(:a) → Functional(identity)
  tₒ = revert(T, apply(T, t)...)
  @test tₒ == t
  @test Tables.schema(tₒ) == Tables.schema(t)
  T = Select(:b) → Functional(identity)
  tₒ = revert(T, apply(T, t)...)
  @test tₒ == t
  @test Tables.schema(tₒ) == Tables.schema(t)

  x1 = rand(4000)
  x2 = rand(4000)
  y1 = rand(4000)
  y2 = rand(4000)
  t = Table(; x1, x2, y1, y2)

  # select columns whose names contain the character x
  T = Select(r"x")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:x1, :x2]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # select columns whose names contain the character y
  T = Select(r"y")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:y1, :y2]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # row table
  rt = Tables.rowtable(t)
  T = Select(r"y")
  n, c = apply(T, rt)
  @test Tables.columnnames(n) == [:y1, :y2]
  rtₒ = revert(T, n, c)
  @test rt == rtₒ

  # throws: Select without arguments
  @test_throws ArgumentError Select()
  @test_throws ArgumentError Select(())

  # throws: empty selection
  @test_throws AssertionError apply(Select(r"a"), t)
  @test_throws AssertionError Select(Symbol[])
  @test_throws AssertionError Select(String[])

  # throws: columns that do not exist in the original table
  @test_throws AssertionError apply(Select(:x3, :y3), t)
  @test_throws AssertionError apply(Select([:x3, :y3]), t)
  @test_throws AssertionError apply(Select((:x3, :y3)), t)
  @test_throws AssertionError apply(Select("x3", "y3"), t)
  @test_throws AssertionError apply(Select(["x3", "y3"]), t)
  @test_throws AssertionError apply(Select(("x3", "y3")), t)
end

@testset "Reject" begin
  a = rand(4000)
  b = rand(4000)
  c = rand(4000)
  d = rand(4000)
  e = rand(4000)
  f = rand(4000)
  t = Table(; a, b, c, d, e, f)

  T = Reject(:f, :d)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:a, :b, :c, :e]
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Reject(:f, :d, :b)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:a, :c, :e]
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Reject(:d, :c, :b)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:a, :e, :f]
  tₒ = revert(T, n, c)
  @test t == tₒ

  T = Reject(:e, :c, :b, :a)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:d, :f]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # rejection with tuples
  T = Reject((:e, :c, :b, :a))
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:d, :f]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # rejection with vectors
  T = Reject([:e, :c, :b, :a])
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:d, :f]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # rejection with strings
  T = Reject("d", "c", "b")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:a, :e, :f]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # rejection with tuple of strings
  T = Reject(("d", "c", "b"))
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:a, :e, :f]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # rejection with vector of strings
  T = Reject(["d", "c", "b"])
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:a, :e, :f]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # rejection with integers
  T = Reject(4, 3, 2)
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:a, :e, :f]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # rejection with tuple of integers
  T = Reject((4, 3, 2))
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:a, :e, :f]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # rejection with vector of integers
  T = Reject([4, 3, 2])
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:a, :e, :f]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # reapply test
  T = Reject(:b, :c, :d)
  n1, c1 = apply(T, t)
  n2 = reapply(T, t, c1)
  @test n1 == n2

  # rejection with Regex
  T = Reject(r"[dcb]")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:a, :e, :f] # the order of columns is preserved
  tₒ = revert(T, n, c)
  @test t == tₒ

  x1 = rand(4000)
  x2 = rand(4000)
  y1 = rand(4000)
  y2 = rand(4000)
  t = Table(; x1, x2, y1, y2)

  # reject columns whose names contain the character x
  T = Reject(r"x")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:y1, :y2]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # reject columns whose names contain the character y
  T = Reject(r"y")
  n, c = apply(T, t)
  @test Tables.columnnames(n) == [:x1, :x2]
  tₒ = revert(T, n, c)
  @test t == tₒ

  # row table
  rt = Tables.rowtable(t)
  T = Reject(r"y")
  n, c = apply(T, rt)
  @test Tables.columnnames(n) == [:x1, :x2]
  rtₒ = revert(T, n, c)
  @test rt == rtₒ

  # throws: Reject without arguments
  @test_throws ArgumentError Reject()
  @test_throws ArgumentError Reject(())

  # throws: empty rejection
  @test_throws AssertionError apply(Reject(r"a"), t)
  @test_throws AssertionError Reject(Symbol[])
  @test_throws AssertionError Reject(String[])

  # throws: reject all columns
  @test_throws AssertionError apply(Reject(r"[xy]"), t)
  @test_throws AssertionError apply(Reject(:x1, :x2, :y1, :y2), t)
  @test_throws AssertionError apply(Reject([:x1, :x2, :y1, :y2]), t)
  @test_throws AssertionError apply(Reject((:x1, :x2, :y1, :y2)), t)
  @test_throws AssertionError apply(Reject("x1", "x2", "y1", "y2"), t)
  @test_throws AssertionError apply(Reject(["x1", "x2", "y1", "y2"]), t)
  @test_throws AssertionError apply(Reject(["x1", "x2", "y1", "y2"]), t)
end

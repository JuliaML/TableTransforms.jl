@testset "Transforms" begin
  # using MersenneTwister for backward
  # compatibility with old Julia versions
  rng = MersenneTwister(42)

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

  @testset "Rename" begin
    a = rand(4000)
    b = rand(4000)
    c = rand(4000)
    d = rand(4000)
    t = Table(; a, b, c, d)

    T = Rename(Dict(:a => :x))
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:x, :b, :c, :d)
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Rename(Dict(:a => :x, :c => :y))
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:x, :b, :y, :d)
    tₒ = revert(T, n, c)
    @test t == tₒ

    # rename with dictionary of strings
    T = Rename(Dict("a" => "x", "c" => "y"))
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:x, :b, :y, :d)
    tₒ = revert(T, n, c)
    @test t == tₒ

    # rename with mixed dictionary
    T = Rename(Dict("a" => :x, :c => "y"))
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:x, :b, :y, :d)
    tₒ = revert(T, n, c)
    @test t == tₒ

    # rename with string pairs
    T = Rename("a" => "x", "c" => "y")
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:x, :b, :y, :d)
    tₒ = revert(T, n, c)
    @test t == tₒ

    # rename with symbol pairs
    T = Rename(:a => :x, :c => :y)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:x, :b, :y, :d)
    tₒ = revert(T, n, c)
    @test t == tₒ

    # rename with mixed pairs
    T = Rename("a" => :x)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:x, :b, :c, :d)
    tₒ = revert(T, n, c)
    @test t == tₒ
    
    T = Rename("a" => :x, :c => "y")
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:x, :b, :y, :d)
    tₒ = revert(T, n, c)
    @test t == tₒ

    # row table
    rt = Tables.rowtable(t)
    T = Rename(:a => :x, :c => :y)
    n, c = apply(T, rt)
    @test Tables.isrowtable(n)
    rtₒ = revert(T, n, c)
    @test rt == rtₒ

    # reapply test
    T = Rename(:b => :x, :d => :y)
    n1, c1 = apply(T, t)
    n2 = reapply(T, t, c1)
    @test n1 == n2
  end

  @testset "StdNames" begin
    names = ["apple banana", "apple\tbanana", "apple_banana", "apple-banana", "apple_Banana"]
    for name in names
      @test TableTransforms._camel(name) == "AppleBanana"
      @test TableTransforms._snake(name) == "apple_banana"
      @test TableTransforms._upper(name) == "APPLEBANANA"
    end

    names = ["a", "A", "_a", "_A", "a ", "A "]
    for name in names
      @test TableTransforms._camel(name) == "A"
      @test TableTransforms._snake(name) == "a"
      @test TableTransforms._upper(name) == "A"
    end

    # special characters
    name = "a&B"
    @test TableTransforms._clean(name) == "aB"
    
    name = "apple#"
    @test TableTransforms._clean(name) == "apple"

    name = "apple-tree"
    @test TableTransforms._clean(name) == "apple-tree"

    # invariance test
    names = ["AppleTree", "BananaFruit", "PearSeed"]
    for name in names
      @test TableTransforms._camel(name) == name
    end

    names = ["apple_tree", "banana_fruit", "pear_seed"]
    for name in names
      @test TableTransforms._snake(name) == name
    end

    names = ["APPLETREE", "BANANAFRUIT", "PEARSEED"]
    for name in names
      @test TableTransforms._upper(name) == name
    end

    # uniqueness test
    names = (Symbol("AppleTree"), Symbol("apple tree"), Symbol("apple_tree"))
    cols = ([1,2,3], [4,5,6], [7,8,9])
    t = Table(; zip(names, cols)...)
    rt = Tables.rowtable(t)
    T = StdNames(:upper)
    n, c = apply(T, rt)
    columns = Tables.columns(n)
    columnnames = Tables.columnnames(columns)
    @test columnnames == (:APPLETREE, :APPLETREE_, :APPLETREE__)
    
    # row table test
    names = (:a, Symbol("apple tree"), Symbol("banana tree"))
    cols = ([1,2,3], [4,5,6], [7,8,9])
    t = Table(; zip(names, cols)...)
    rt = Tables.rowtable(t)
    T = StdNames()
    n, c = apply(T, rt)
    @test Tables.isrowtable(n)
    @test isrevertible(T)
    rtₒ = revert(T, n, c)
    @test rt == rtₒ

    # reapply test
    T = StdNames()
    n1, c1 = apply(T, rt)
    n2 = reapply(T, n1, c1)
    @test n1 == n2
  end

  @testset "Sort" begin
    a = [5, 3, 1, 2]
    b = [2, 4, 8, 5]
    c = [3, 2, 1, 4]
    d = [4, 3, 7, 5]
    t = Table(; a, b, c, d)

    T = Sort(:a)
    n, c = apply(T, t)
    @test Tables.schema(t) == Tables.schema(n)
    @test n.a == [1, 2, 3, 5]
    @test n.b == [8, 5, 4, 2]
    @test n.c == [1, 4, 2, 3]
    @test n.d == [7, 5, 3, 4]
    @test isrevertible(T) == true
    tₒ = revert(T, n, c)
    @test t == tₒ

    # descending order test
    T = Sort(:b, rev=true)
    n, c = apply(T, t)
    @test Tables.schema(t) == Tables.schema(n)
    @test n.a == [1, 2, 3, 5]
    @test n.b == [8, 5, 4, 2]
    @test n.c == [1, 4, 2, 3]
    @test n.d == [7, 5, 3, 4]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # random test
    a = rand(200)
    b = rand(200)
    c = rand(200)
    d = rand(200)
    t = Table(; a, b, c, d)

    T = Sort(:c)
    n, c = apply(T, t)

    @test Tables.schema(t) == Tables.schema(n)
    @test issetequal(Tables.rowtable(t), Tables.rowtable(n))
    @test issorted(Tables.getcolumn(n, :c))
    tₒ = revert(T, n, c)
    @test t == tₒ

    # sort by multiple columns
    a = [-2, -1, -2, 2, 1, -1, 1, 2]
    b = [-8, -4, 6, 9, 8, 2, 2, -8]
    c = [-3, 6, 5, 4, -8, -7, -1, -10]
    t = Table(; a, b, c)

    T = Sort(1, 2)
    n, c = apply(T, t)
    @test n.a == [-2, -2, -1, -1, 1, 1, 2, 2]
    @test n.b == [-8, 6, -4, 2, 2, 8, -8, 9]
    @test n.c == [-3, 5, 6, -7, -1, -8, -10, 4]
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Sort([:a, :c], rev=true)
    n, c = apply(T, t)
    @test n.a == [2, 2, 1, 1, -1, -1, -2, -2]
    @test n.b == [9, -8, 2, 8, -4, 2, 6, -8]
    @test n.c == [4, -10, -1, -8, 6, -7, 5, -3]
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Sort(("b", "c"), by=row -> abs.(row))
    n, c = apply(T, t)
    @test n.a == [1, -1, -1, -2, -2, 1, 2, 2]
    @test n.b == [2, 2, -4, 6, -8, 8, -8, 9]
    @test n.c == [-1, -7, 6, 5, -3, -8, -10, 4]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # throws: Sort without arguments
    @test_throws ArgumentError Sort()
    @test_throws ArgumentError Sort(())

    # throws: empty selection
    @test_throws AssertionError apply(Sort(r"x"), t)
    @test_throws AssertionError Sort(Symbol[])
    @test_throws AssertionError Sort(String[])

    # throws: columns that do not exist in the original table
    @test_throws AssertionError apply(Sort([:d, :e]), t)
    @test_throws AssertionError apply(Sort(("d", "e")), t)

    # Invalid kwarg
    @test_throws MethodError apply(Sort(:a, :b, test=1), t)
  end

  @testset "Sample" begin
    a = [3, 6, 2, 7, 8, 3]
    b = [8, 5, 1, 2, 3, 4]
    c = [1, 8, 5, 2, 9, 4]
    t = Table(; a, b, c)
    trows = Tables.rowtable(t) 

    T = Sample(30)
    n, c = apply(T, t)
    @test length(n.a) == 30

    T = Sample(6, replace=false)
    n, c = apply(T, t)
    @test n.a ⊆ t.a
    @test n.b ⊆ t.b
    @test n.c ⊆ t.c

    T = Sample(30, ordered=true)
    n, c = apply(T, t)
    @test unique(Tables.rowtable(n)) == trows

    T = Sample(6, replace=false, ordered=true)
    n, c = apply(T, t)
    @test n.a ⊆ t.a
    @test n.b ⊆ t.b
    @test n.c ⊆ t.c
    @test Tables.rowtable(n) == trows

    # with rng
    T = Sample(MersenneTwister(2), 8)
    n, c = apply(T, t)
    @test n.a == [3, 7, 8, 2, 2, 6, 2, 6]
    @test n.b == [8, 2, 3, 1, 1, 5, 1, 5]
    @test n.c == [1, 2, 9, 5, 5, 8, 5, 8]

    #with weights
    wv = pweights([0.1, 0.25, 0.15, 0.25, 0.1, 0.15])
    T = Sample(MersenneTwister(2), wv, 10_000)
    n, c = apply(T, t)
    nrows = Tables.rowtable(n)
    @test isapprox(count(==(trows[1]), nrows) / 10_000, 0.10, atol=0.01)
    @test isapprox(count(==(trows[2]), nrows) / 10_000, 0.25, atol=0.01)
    @test isapprox(count(==(trows[3]), nrows) / 10_000, 0.15, atol=0.01)
    @test isapprox(count(==(trows[4]), nrows) / 10_000, 0.25, atol=0.01)
    @test isapprox(count(==(trows[5]), nrows) / 10_000, 0.10, atol=0.01)
    @test isapprox(count(==(trows[6]), nrows) / 10_000, 0.15, atol=0.01)

    # throws
    @test_throws AssertionError revert(T, n, c)
  end

  @testset "Filter" begin
    a = [3, 2, 1, 4, 5, 3]
    b = [2, 4, 4, 5, 8, 5]
    c = [1, 1, 6, 2, 4, 1]
    d = [4, 3, 7, 5, 4, 1]
    e = [5, 5, 2, 6, 5, 2]
    f = [4, 4, 3, 4, 5, 2]
    t = Table(; a, b, c, d, e, f)

    T = Filter(row -> all(≤(5), row))
    n, c = apply(T, t)
    @test n.a == [3, 2, 3]
    @test n.b == [2, 4, 5]
    @test n.c == [1, 1, 1]
    @test n.d == [4, 3, 1]
    @test n.e == [5, 5, 2]
    @test n.f == [4, 4, 2]

    # revert test
    @test isrevertible(T) == true
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Filter(row -> any(>(5), row))
    n, c = apply(T, t)
    @test n.a == [1, 4, 5]
    @test n.b == [4, 5, 8]
    @test n.c == [6, 2, 4]
    @test n.d == [7, 5, 4]
    @test n.e == [2, 6, 5]
    @test n.f == [3, 4, 5]
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Filter(row -> row.a ≥ 3)
    n, c = apply(T, t)
    @test n.a == [3, 4, 5, 3]
    @test n.b == [2, 5, 8, 5]
    @test n.c == [1, 2, 4, 1]
    @test n.d == [4, 5, 4, 1]
    @test n.e == [5, 6, 5, 2]
    @test n.f == [4, 4, 5, 2]
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Filter(row -> row.c ≥ 2 && row.e > 4)
    n, c = apply(T, t)
    @test n.a == [4, 5]
    @test n.b == [5, 8]
    @test n.c == [2, 4]
    @test n.d == [5, 4]
    @test n.e == [6, 5]
    @test n.f == [4, 5]
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = Filter(row -> row.b == 4 || row.f == 4)
    n, c = apply(T, t)
    @test n.a == [3, 2, 1, 4]
    @test n.b == [2, 4, 4, 5]
    @test n.c == [1, 1, 6, 2]
    @test n.d == [4, 3, 7, 5]
    @test n.e == [5, 5, 2, 6]
    @test n.f == [4, 4, 3, 4]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # reapply test
    T = Filter(row -> all(≤(5), row))
    n1, c1 = apply(T, t)
    n2 = reapply(T, t, c1)
    @test n1 == n2

    # row table
    rt = Tables.rowtable(t)
    T = Filter(row -> row.b == 4 || row.f == 4)
    n, c = apply(T, rt)
    @test Tables.isrowtable(n)
    rtₒ = revert(T, n, c)
    @test rt == rtₒ
  end

  @testset "DropMissing" begin
    a = [3, 2, missing, 4, 5, 3]
    b = [missing, 4, 4, 5, 8, 5]
    c = [1, 1, 6, 2, 4, missing]
    d = [4, 3, 7, 5, 4, missing]
    e = [missing, 5, 2, 6, 5, 2]
    f = [4, missing, 3, 4, 5, 2]
    t = Table(; a, b, c, d, e, f)

    T = DropMissing()
    n, c = apply(T, t)
    @test n.a == [4, 5]
    @test n.b == [5, 8]
    @test n.c == [2, 4]
    @test n.d == [5, 4]
    @test n.e == [6, 5]
    @test n.f == [4, 5]

    # revert test
    @test isrevertible(T) == true
    tₒ = revert(T, n, c)
    cols = Tables.columns(t)
    colsₒ = Tables.columns(tₒ)
    colnames = Tables.columnnames(t)
    for n in colnames
      col = Tables.getcolumn(cols, n)
      colₒ = Tables.getcolumn(colsₒ, n)
      @test isequalmissing(col, colₒ)
    end

    # args...
    # integers
    T = DropMissing(1, 3, 4)
    n, c = apply(T, t)
    @test isequalmissing(n.a, [3, 2, 4, 5])
    @test isequalmissing(n.b, [missing, 4, 5, 8])
    @test isequalmissing(n.c, [1, 1, 2, 4])
    @test isequalmissing(n.d, [4, 3, 5, 4])
    @test isequalmissing(n.e, [missing, 5, 6, 5])
    @test isequalmissing(n.f, [4, missing, 4, 5])

    # symbols
    T = DropMissing(:a, :c, :d)
    n, c = apply(T, t)
    @test isequalmissing(n.a, [3, 2, 4, 5])
    @test isequalmissing(n.b, [missing, 4, 5, 8])
    @test isequalmissing(n.c, [1, 1, 2, 4])
    @test isequalmissing(n.d, [4, 3, 5, 4])
    @test isequalmissing(n.e, [missing, 5, 6, 5])
    @test isequalmissing(n.f, [4, missing, 4, 5])

    # strings
    T = DropMissing("a", "c", "d")
    n, c = apply(T, t)
    @test isequalmissing(n.a, [3, 2, 4, 5])
    @test isequalmissing(n.b, [missing, 4, 5, 8])
    @test isequalmissing(n.c, [1, 1, 2, 4])
    @test isequalmissing(n.d, [4, 3, 5, 4])
    @test isequalmissing(n.e, [missing, 5, 6, 5])
    @test isequalmissing(n.f, [4, missing, 4, 5])

    # vector
    # integers
    T = DropMissing([1, 3, 4])
    n, c = apply(T, t)
    @test isequalmissing(n.a, [3, 2, 4, 5])
    @test isequalmissing(n.b, [missing, 4, 5, 8])
    @test isequalmissing(n.c, [1, 1, 2, 4])
    @test isequalmissing(n.d, [4, 3, 5, 4])
    @test isequalmissing(n.e, [missing, 5, 6, 5])
    @test isequalmissing(n.f, [4, missing, 4, 5])

    # symbols
    T = DropMissing([:a, :c, :d])
    n, c = apply(T, t)
    @test isequalmissing(n.a, [3, 2, 4, 5])
    @test isequalmissing(n.b, [missing, 4, 5, 8])
    @test isequalmissing(n.c, [1, 1, 2, 4])
    @test isequalmissing(n.d, [4, 3, 5, 4])
    @test isequalmissing(n.e, [missing, 5, 6, 5])
    @test isequalmissing(n.f, [4, missing, 4, 5])

    # strings
    T = DropMissing(["a", "c", "d"])
    n, c = apply(T, t)
    @test isequalmissing(n.a, [3, 2, 4, 5])
    @test isequalmissing(n.b, [missing, 4, 5, 8])
    @test isequalmissing(n.c, [1, 1, 2, 4])
    @test isequalmissing(n.d, [4, 3, 5, 4])
    @test isequalmissing(n.e, [missing, 5, 6, 5])
    @test isequalmissing(n.f, [4, missing, 4, 5])

    # tuple
    # integers
    T = DropMissing((1, 3, 4))
    n, c = apply(T, t)
    @test isequalmissing(n.a, [3, 2, 4, 5])
    @test isequalmissing(n.b, [missing, 4, 5, 8])
    @test isequalmissing(n.c, [1, 1, 2, 4])
    @test isequalmissing(n.d, [4, 3, 5, 4])
    @test isequalmissing(n.e, [missing, 5, 6, 5])
    @test isequalmissing(n.f, [4, missing, 4, 5])

    # symbols
    T = DropMissing((:a, :c, :d))
    n, c = apply(T, t)
    @test isequalmissing(n.a, [3, 2, 4, 5])
    @test isequalmissing(n.b, [missing, 4, 5, 8])
    @test isequalmissing(n.c, [1, 1, 2, 4])
    @test isequalmissing(n.d, [4, 3, 5, 4])
    @test isequalmissing(n.e, [missing, 5, 6, 5])
    @test isequalmissing(n.f, [4, missing, 4, 5])

    # strings
    T = DropMissing(("a", "c", "d"))
    n, c = apply(T, t)
    @test isequalmissing(n.a, [3, 2, 4, 5])
    @test isequalmissing(n.b, [missing, 4, 5, 8])
    @test isequalmissing(n.c, [1, 1, 2, 4])
    @test isequalmissing(n.d, [4, 3, 5, 4])
    @test isequalmissing(n.e, [missing, 5, 6, 5])
    @test isequalmissing(n.f, [4, missing, 4, 5])

    # regex
    T = DropMissing(r"[acd]")
    n, c = apply(T, t)
    @test isequalmissing(n.a, [3, 2, 4, 5])
    @test isequalmissing(n.b, [missing, 4, 5, 8])
    @test isequalmissing(n.c, [1, 1, 2, 4])
    @test isequalmissing(n.d, [4, 3, 5, 4])
    @test isequalmissing(n.e, [missing, 5, 6, 5])
    @test isequalmissing(n.f, [4, missing, 4, 5])

    # table schema after apply and revert
    T = DropMissing()
    n, c = apply(T, t)
    tₒ = revert(T, n, c)
    ttypes = Tables.schema(t).types
    ntypes = Tables.schema(n).types
    @test ntypes[1] == Int
    @test ntypes[2] == Int
    @test ntypes[3] == Int
    @test ntypes[4] == Int
    @test ntypes[5] == Int
    @test ntypes[6] == Int
    @test ttypes == Tables.schema(tₒ).types

    T = DropMissing([:a, :c, :d])
    n, c = apply(T, t)
    tₒ = revert(T, n, c)
    ntypes = Tables.schema(n).types
    @test ntypes[1] == Int
    @test ntypes[2] == Union{Missing,Int}
    @test ntypes[3] == Int
    @test ntypes[4] == Int
    @test ntypes[5] == Union{Missing,Int}
    @test ntypes[6] == Union{Missing,Int}
    @test ttypes == Tables.schema(tₒ).types

    T = DropMissing([:b, :e, :f])
    n, c = apply(T, t)
    tₒ = revert(T, n, c)
    ntypes = Tables.schema(n).types
    @test ntypes[1] == Union{Missing,Int}
    @test ntypes[2] == Int
    @test ntypes[3] == Union{Missing,Int}
    @test ntypes[4] == Union{Missing,Int}
    @test ntypes[5] == Int
    @test ntypes[6] == Int
    @test ttypes == Tables.schema(tₒ).types

    # reapply test
    T = DropMissing()
    n1, c1 = apply(T, t)
    n2 = reapply(T, t, c1)
    @test n1 == n2

    # row table
    rt = Tables.rowtable(t)
    T = DropMissing()
    n, c = apply(T, rt)
    @test Tables.isrowtable(n)
    rtₒ = revert(T, n, c)
    for (row, rowₒ) in zip(rt, rtₒ)
      @test isequalmissing(row, rowₒ)
    end

    # throws: empty tuple
    @test_throws ArgumentError DropMissing(())

    # throws: empty selection
    @test_throws AssertionError apply(DropMissing(r"g"), t)
    @test_throws AssertionError DropMissing(Symbol[])
    @test_throws AssertionError DropMissing(String[])

    # throws: columns that do not exist in the original table
    @test_throws AssertionError apply(DropMissing(:g, :h), t)
    @test_throws AssertionError apply(DropMissing([:g, :h]), t)
    @test_throws AssertionError apply(DropMissing((:g, :h)), t)
    @test_throws AssertionError apply(DropMissing("g", "h"), t)
    @test_throws AssertionError apply(DropMissing(["g", "h"]), t)
    @test_throws AssertionError apply(DropMissing(("g", "h")), t)
  end

  @testset "Replace" begin
    a = [3, 2, 1, 4, 5, 3]
    b = [2, 4, 4, 5, 8, 5]
    c = [1, 1, 6, 2, 4, 1]
    d = [4, 3, 7, 5, 4, 1]
    e = [5, 5, 2, 6, 5, 2]
    f = [4, 4, 3, 4, 5, 2]
    t = Table(; a, b, c, d, e, f)

    # replace with a value of the same type
    T = Replace(1 => -1, 5 => -5)
    n, c = apply(T, t)
    @test n.a == [3, 2, -1, 4, -5, 3]
    @test n.b == [2, 4, 4, -5, 8, -5]
    @test n.c == [-1, -1, 6, 2, 4, -1]
    @test n.d == [4, 3, 7, -5, 4, -1]
    @test n.e == [-5, -5, 2, 6, -5, 2]
    @test n.f == [4, 4, 3, 4, -5, 2]
    @test isrevertible(T) == true
    tₒ = revert(T, n, c)
    @test t == tₒ

    # table schema after apply and revert
    T = Replace(1 => -1, 5 => -5)
    n, c = apply(T, t)
    types = Tables.schema(t).types
    @test types == Tables.schema(n).types
    tₒ = revert(T, n, c)
    @test types == Tables.schema(tₒ).types

    # replace with a value of another type
    T = Replace(1 => 1.5, 5 => 5.5, 4 => true)
    n, c = apply(T, t)
    @test n.a == Real[3, 2, 1.5, true, 5.5, 3]
    @test n.b == Real[2, true, true, 5.5, 8, 5.5]
    @test n.c == Real[1.5, 1.5, 6, 2, true, 1.5]
    @test n.d == Real[true, 3, 7, 5.5, true, 1.5]
    @test n.e == Real[5.5, 5.5, 2, 6, 5.5, 2]
    @test n.f == Real[true, true, 3, true, 5.5, 2]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # table schema after apply and revert
    T = Replace(1 => 1.5, 5 => 5.5, 4 => true)
    n, c = apply(T, t)
    tₒ = revert(T, n, c)
    ttypes = Tables.schema(t).types
    ntypes = Tables.schema(n).types
    @test ntypes[1] == Real
    @test ntypes[2] == Real
    @test ntypes[3] == Real
    @test ntypes[4] == Real
    @test ntypes[5] == Real
    @test ntypes[6] == Real
    @test ttypes == Tables.schema(tₒ).types

    # no occurrences
    T = Replace(10 => 11, 20 => 30)
    n, c = apply(T, t)
    @test t == n
    tₒ = revert(T, n, c)
    @test t == tₒ
    
    # collumns with diferent types
    a = [3, 2, 1, 4, 5, 3]
    b = [2.5, 4.5, 4.7, 2.5, 2.5, 5.3]
    c = [true, false, false, false, true, false]
    d = ['a', 'b', 'c', 'd', 'e', 'a']
    t = Table(; a, b, c, d)

    T = Replace(3 => -3, 2.5 => 2.0, true => false, 'a' => 'A')
    n, c = apply(T, t)
    @test n.a == [-3, 2, 1, 4, 5, -3]
    @test n.b == [2.0, 4.5, 4.7, 2.0, 2.0, 5.3]
    @test n.c == [false, false, false, false, false, false]
    @test n.d == ['A', 'b', 'c', 'd', 'e', 'A']
    tₒ = revert(T, n, c)
    @test t == tₒ

    # row table
    rt = Tables.rowtable(t)
    T = Replace(3 => -3, 2.5 => 2.0)
    n, c = apply(T, rt)
    @test Tables.isrowtable(n)
    rtₒ = revert(T, n, c)
    @test rt == rtₒ

    # throws
    @test_throws ArgumentError Replace()
  end

  @testset "Coalesce" begin
    a = [3, 2, missing, 4, 5, 3]
    b = [missing, 4, 4, 5, 8, 5]
    c = [1, 1, 6, 2, 4, missing]
    d = [4, 3, 7, 5, 4, missing]
    e = [missing, 5, 2, 6, 5, 2]
    f = [4, missing, 3, 4, 5, 2]
    t = Table(; a, b, c, d, e, f)

    T = Coalesce(0)
    n, c = apply(T, t)
    @test n.a == [3, 2, 0, 4, 5, 3]
    @test n.b == [0, 4, 4, 5, 8, 5]
    @test n.c == [1, 1, 6, 2, 4, 0]
    @test n.d == [4, 3, 7, 5, 4, 0]
    @test n.e == [0, 5, 2, 6, 5, 2]
    @test n.f == [4, 0, 3, 4, 5, 2]

    # revert test
    @test isrevertible(T) == true
    tₒ = revert(T, n, c)
    cols = Tables.columns(t)
    colsₒ = Tables.columns(tₒ)
    colnames = Tables.columnnames(t)
    for n in colnames
      col = Tables.getcolumn(cols, n)
      colₒ = Tables.getcolumn(colsₒ, n)
      @test isequalmissing(col, colₒ)
    end

    # table schema after apply and revert
    T = Coalesce(0)
    n, c = apply(T, t)
    tₒ = revert(T, n, c)
    ttypes = Tables.schema(t).types
    ntypes = Tables.schema(n).types
    @test ntypes[1] == Int
    @test ntypes[2] == Int
    @test ntypes[3] == Int
    @test ntypes[4] == Int
    @test ntypes[5] == Int
    @test ntypes[6] == Int
    @test ttypes == Tables.schema(tₒ).types  
    
    # row table
    rt = Tables.rowtable(t)
    T = Coalesce(0)
    n, c = apply(T, rt)
    @test Tables.isrowtable(n)
    rtₒ = revert(T, n, c)
    for (row, rowₒ) in zip(rt, rtₒ)
      @test isequalmissing(row, rowₒ)
    end
  end
  
  @testset "Coerce" begin
    x1 = [1.0, 2.0, 3.0, 4.0, 5.0]
    x2 = [1.0, 2.0, 3.0, 4.0, 5.0]
    x3 = [5.0, 5.0, 5.0, 5.0, 5.0]
    t = Table(;x1, x2, x3)

    T = Coerce(:x1=>Count, :x2=>Count)
    n, c = apply(T, t)
    @test eltype(n.x1) == Int
    @test eltype(n.x2) == Int
    n, c = apply(T, t)
    tₒ = revert(T, n, c)
    @test eltype(tₒ.x1) == eltype(t.x1)
    @test eltype(tₒ.x2) == eltype(t.x2)

    T = Coerce(:x1=>Multiclass, :x2=>Multiclass)
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

  @testset "Levels" begin
    a = categorical(rand([true, false], 50))
    b = categorical(rand(["y", "n"], 50))
    c = categorical(rand(1:3, 50))
    t = Table(; a, b, c)

    T = Levels(2 => ["n", "y", "m"])
    n, c = apply(T, t)
    @test levels(n.b) == ["n", "y", "m"]
    @test isordered(n.b) == false
    tₒ = revert(T, n, c)
    @test tₒ == t

    T = Levels(:b => ["n", "y", "m"], :c => 1:4, ordered=[:c])
    n, c = apply(T, t)
    @test levels(n.b) == ["n", "y", "m"]
    @test isordered(n.b) == false
    @test levels(n.c) == [1, 2, 3, 4]
    @test isordered(n.c) == true
    tₒ = revert(T, n, c)
    @test tₒ == t

    T = Levels("b" => ["n", "y", "m"], "c" => 1:4, ordered=["b"])
    n, c = apply(T, t)
    @test levels(n.b) == ["n", "y", "m"]
    @test isordered(n.b) == true
    @test levels(n.c) == [1, 2, 3, 4]
    @test isordered(n.c) == false
    tₒ = revert(T, n, c)
    @test tₒ == t

    a = categorical(["yes", "no", "no", "no", "yes"]) 
    b = categorical([1, 2, 4, 2, 8], ordered=false) 
    c = categorical([1, 2, 1, 2, 1]) 
    d = categorical([1, 23, 5, 7, 7])
    e = categorical([2, 3, 1, 4, 1])
    t = Table(; a, b, c, d, e)

    T = Levels(:a => ["yes", "no"], :c => [1, 2, 4], :d => [1, 23, 5, 7], :e => 1:5)
    n, c = apply(T, t)
    @test levels(n.a) == ["yes", "no"]
    @test levels(n.c) == [1, 2, 4]
    @test levels(n.d) == [1, 23, 5, 7]
    @test levels(n.e) == [1, 2, 3, 4, 5]
    tₒ = revert(T, n, c)
    @test levels(tₒ.a) == ["no", "yes"]
    @test levels(tₒ.c) == [1, 2]
    @test levels(tₒ.e) == [1, 2, 3, 4]

    T = Levels("a" => ["yes", "no"], "c" => [1, 2, 4])
    n, c = apply(T, t)
    @test levels(n.a) == ["yes", "no"]
    @test levels(n.c) == [1, 2, 4]
    tₒ = revert(T, n, c)
    @test levels(tₒ.a) == ["no", "yes"]
    @test levels(tₒ.c) == [1, 2]

    T = Levels(:a => ["yes", "no"], :c => [1, 2, 4], :d => [1, 23, 5, 7])
    n, c = apply(T, t)
    @test levels(n.a) == ["yes", "no"]
    @test levels(n.c) == [1, 2, 4]
    @test levels(n.d) == [1, 23, 5, 7]
    tₒ = revert(T, n, c)
    @test levels(tₒ.a) == ["no", "yes"]
    @test levels(tₒ.c) == [1, 2]

    T = Levels("a" => ["yes", "no"], "c" => [1, 2, 4], "e" => 5:-1:1, ordered=["e"])
    n, c = apply(T, t)
    @test levels(n.a) == ["yes", "no"]
    @test levels(n.c) == [1, 2, 4]
    @test levels(n.e) == [5, 4, 3, 2, 1]
    @test isordered(n.a) == false
    @test isordered(n.c) == false
    @test isordered(n.e) == true
    tₒ = revert(T, n, c)
    @test levels(tₒ.e) == [1, 2, 3, 4]
    @test isordered(tₒ.e) == false

    T = Levels(:a => ["yes", "no"], :c => [1, 2, 4], :d => [1, 23, 5, 7], ordered=[:a, :d])
    n, c = apply(T, t)
    @test levels(n.a) == ["yes", "no"]
    @test levels(n.c) == [1, 2, 4]
    @test levels(n.d) == [1, 23, 5, 7]
    @test isordered(n.a) == true
    @test isordered(n.c) == false
    @test isordered(n.d) == true
    tₒ = revert(T, n, c)
    @test isordered(tₒ.a) == false

    a = rand([true, false], 50)
    b = categorical(rand(["y", "n"], 50))
    c = categorical(rand(1:3, 50))
    t = Table(; a, b, c)

    # throws: Levels without arguments
    @test_throws ArgumentError Levels()

    # throws: columns that do not exist in the original table
    T = Levels(:x => ["n", "y", "m"], :y => 1:4)
    @test_throws AssertionError apply(T, t)
    T = Levels("x" => ["n", "y", "m"], "y" => 1:4)
    @test_throws AssertionError apply(T, t)

    # throws: non categorical collumn
    T = Levels(:a => [true, false], ordered=[:a])
    @test_throws AssertionError apply(T, t)

    # throws: invalid ordered column selection
    T = Levels(:b => ["n", "y", "m"], :c => 1:4, ordered=[:a])
    @test_throws AssertionError apply(T, t)
    T = Levels("b" => ["n", "y", "m"], "c" => 1:4, ordered=["a"])
    @test_throws AssertionError apply(T, t)
    T = Levels("b" => ["n", "y", "m"], "c" => 1:4, ordered=r"xy")
    @test_throws AssertionError apply(T, t)
  end

  @testset "OneHot" begin
    a = categorical(Bool[0, 1, 1, 0, 1, 1])
    b = categorical(["m", "f", "m", "m", "m", "f"])
    c = categorical([3, 2, 2, 1, 1, 3])
    t = Table(; a, b, c)

    T = OneHot(1)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:a_false, :a_true, :b, :c)
    @test n.a_false == Bool[1, 0, 0, 1, 0, 0]
    @test n.a_true  == Bool[0, 1, 1, 0, 1, 1]
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = OneHot(:b)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:a, :b_f, :b_m, :c)
    @test n.b_f == Bool[0, 1, 0, 0, 0, 1]
    @test n.b_m == Bool[1, 0, 1, 1, 1, 0]
    tₒ = revert(T, n, c)
    @test t == tₒ

    T = OneHot("c")
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:a, :b, :c_1, :c_2, :c_3)
    @test n.c_1 == Bool[0, 0, 0, 1, 1, 0]
    @test n.c_2 == Bool[0, 1, 1, 0, 0, 0]
    @test n.c_3 == Bool[1, 0, 0, 0, 0, 1]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # name formatting
    b   = categorical(["m", "f", "m", "m", "m", "f"])
    b_f = rand(10)
    b_m = rand(10)
    t   = Table(; b, b_f, b_m)

    T = OneHot(:b)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:b_f_, :b_m_, :b_f, :b_m)
    @test n.b_f_ == Bool[0, 1, 0, 0, 0, 1]
    @test n.b_m_ == Bool[1, 0, 1, 1, 1, 0]
    tₒ = revert(T, n, c)
    @test t == tₒ

    b    = categorical(["m", "f", "m", "m", "m", "f"])
    b_f  = rand(10)
    b_m  = rand(10)
    b_f_ = rand(10)
    b_m_ = rand(10)
    t    = Table(; b, b_f, b_m, b_f_, b_m_)

    T = OneHot(:b)
    n, c = apply(T, t)
    @test Tables.columnnames(n) == (:b_f__, :b_m__, :b_f, :b_m, :b_f_, :b_m_)
    @test n.b_f__ == Bool[0, 1, 0, 0, 0, 1]
    @test n.b_m__ == Bool[1, 0, 1, 1, 1, 0]
    tₒ = revert(T, n, c)
    @test t == tₒ

    # throws
    a = categorical(Bool[0, 1, 1, 0, 1, 1])
    b = ["m", "f", "m", "m", "m", "f"]
    t = Table(; a, b)

    # non categorical column
    @test_throws AssertionError apply(OneHot(:b), t)
    @test_throws AssertionError apply(OneHot("b"), t)

    # invalid column selection
    @test_throws AssertionError apply(OneHot(:c), t)
    @test_throws AssertionError apply(OneHot("c"), t)
  end

  @testset "Identity" begin
    x = rand(4000)
    y = rand(4000)
    t = Table(; x, y)
    T = Identity()
    n, c = apply(T, t)
    @test t == n
    tₒ = revert(T, n, c)
    @test t == tₒ

    # row table
    rt = Tables.rowtable(t)
    T = Identity()
    n, c = apply(T, rt)
    @test Tables.isrowtable(n)
    rtₒ = revert(T, n, c)
    @test rt == rtₒ
  end

  @testset "Center" begin
    x = rand(rng, Normal(2, 1), 4000)
    y = rand(rng, Normal(5, 1), 4000)
    t = Table(; x, y)
    T = Center()
    n, c = apply(T, t)
    μ = mean(Tables.matrix(n), dims=1)
    @test isapprox(μ[1], 0; atol=1e-6)
    @test isapprox(μ[2], 0; atol=1e-6)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    # visual tests    
    if visualtests
      p₁ = scatter(t.x, t.y, label="Original")
      p₂ = scatter(n.x, n.y, label="Center")
      p = plot(p₁, p₂, layout=(1,2))

      @test_reference joinpath(datadir, "center.png") p
    end

    # row table
    rt = Tables.rowtable(t)
    T = Center()
    n, c = apply(T, rt)
    @test Tables.isrowtable(n)
    rtₒ = revert(T, n, c)
    @test Tables.matrix(rt) ≈ Tables.matrix(rtₒ)
  end

  @testset "Scale" begin
    # constant column
    x = fill(3.0, 10)
    y = rand(10)
    t = Table(; x, y)
    T = MinMax()
    n, c = apply(T, t)
    @test n.x == x
    @test n.y != y
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = rand(rng, Normal(4, 3), 4000)
    y = rand(rng, Normal(7, 5), 4000)
    t = Table(; x, y)
    T = Scale(low=0, high=1)
    n, c = apply(T, t)
    @test all(≤(1), n.x)
    @test all(≥(0), n.x)
    @test all(≤(1), n.y)
    @test all(≥(0), n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    # visual tests   
    if visualtests
      p₁ = scatter(t.x, t.y, label="Original")
      p₂ = scatter(n.x, n.y, label="Scale")
      p = plot(p₁, p₂, layout=(1,2))

      @test_reference joinpath(datadir, "scale.png") p
    end

    # row table
    rt = Tables.rowtable(t)
    T = Scale()
    n, c = apply(T, rt)
    @test Tables.isrowtable(n)
    rtₒ = revert(T, n, c)
    @test Tables.matrix(rt) ≈ Tables.matrix(rtₒ)

    # columntype does not change
    for FT in (Float16, Float32)
      t = Table(; x=rand(FT, 10))
      for T in (MinMax(), Scale(FT(0), FT(0.5)))
        n, c = apply(T, t)
        @test Tables.columntype(t, :x) == Tables.columntype(n, :x)
        tₒ = revert(T, n, c)
        @test Tables.columntype(t, :x) == Tables.columntype(tₒ, :x)
      end
    end
  end

  @testset "ZScore" begin
    x = rand(rng, Normal(7, 10), 4000)
    y = rand(rng, Normal(15, 2), 4000)
    t = Table(; x, y)
    T = ZScore()
    n, c = apply(T, t)
    μ = mean(Tables.matrix(n), dims=1)
    σ = std(Tables.matrix(n), dims=1)
    @test isapprox(μ[1], 0; atol=1e-6)
    @test isapprox(σ[1], 1; atol=1e-6)
    @test isapprox(μ[2], 0; atol=1e-6)
    @test isapprox(σ[2], 1; atol=1e-6)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    # visual tests   
    if visualtests
      p₁ = scatter(t.x, t.y, label="Original")
      p₂ = scatter(n.x, n.y, label="ZScore")
      p = plot(p₁, p₂, layout=(1,2))

      @test_reference joinpath(datadir, "zscore.png") p
    end

    # row table
    rt = Tables.rowtable(t)
    T = ZScore()
    n, c = apply(T, rt)
    @test Tables.isrowtable(n)
    rtₒ = revert(T, n, c)
    @test Tables.matrix(rt) ≈ Tables.matrix(rtₒ)

    # make sure transform works with single-column tables
    t = Table(x=rand(10000))
    n, c = apply(ZScore(), t)
    r = revert(ZScore(), n, c)
    @test isapprox(mean(n.x), 0.0, atol=1e-8)
    @test isapprox(std(n.x), 1.0, atol=1e-8)
    @test isapprox(mean(r.x), mean(t.x), atol=1e-8)
    @test isapprox(std(r.x), std(t.x), atol=1e-8)
  end

  @testset "Quantile" begin
    t = (z=rand(1000),)
    n, c = apply(Quantile(), t)
    r = revert(Quantile(), n, c)
    @test all(-4 .< extrema(n.z) .< 4)
    @test all(0 .≤ extrema(r.z) .≤ 1)

    # constant column
    x = fill(3.0, 10)
    y = rand(10)
    t = Table(; x, y)
    T = Quantile()
    n, c = apply(T, t)
    @test maximum(abs, n.x - x) < 0.1
    @test n.y != y
    tₒ = revert(T, n, c)
    @test tₒ.x == t.x

    # row table
    rt = Tables.rowtable(t)
    T = Quantile()
    n, c = apply(T, rt)
    @test Tables.isrowtable(n)
    rtₒ = revert(T, n, c)
    for (row, rowₒ) in zip(rt, rtₒ)
      @test row.x == rowₒ.x
    end
  end

  @testset "Functional" begin
    x = π*rand(1500)
    y = π*rand(1500)
    t = Table(; x, y)
    T = Functional(cos)
    n, c = apply(T, t)
    @test all(x -> -1 ≤ x ≤ 1, n.x)
    @test all(y -> -1 ≤ y ≤ 1, n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = 2*(rand(1500) .- 0.5)
    y = 2*(rand(1500) .- 0.5)
    t = Table(; x, y)
    T = Functional(acos)
    n, c = apply(T, t)
    @test all(x -> 0 ≤ x ≤ π, n.x)
    @test all(y -> 0 ≤ y ≤ π, n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = π*(rand(1500) .- 0.5)
    y = π*(rand(1500) .- 0.5)
    t = Table(; x, y)
    T = Functional(sin)
    n, c = apply(T, t)
    @test all(x -> -1 ≤ x ≤ 1, n.x)
    @test all(y -> -1 ≤ y ≤ 1, n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = 2*(rand(1500) .- 0.5)
    y = 2*(rand(1500) .- 0.5)
    t = Table(; x, y)
    T = Functional(asin)
    n, c = apply(T, t)
    @test all(x -> -π/2 ≤ x ≤ π/2, n.x)
    @test all(y -> -π/2 ≤ y ≤ π/2, n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = rand(Normal(0,25), 1500)
    y = x + rand(Normal(10,2), 1500)
    t = Table(; x, y)
    T = Functional(exp)
    n, c = apply(T, t)
    @test all(>(0), n.x)
    @test all(>(0), n.y)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = rand(Normal(0,25), 1500)
    y = x + rand(Normal(10,2), 1500)
    t = Table(; x, y)
    T = Functional(x -> x)
    n, c = apply(T, t)
    @test t == n
    @test isrevertible(T) == false

    # functor tests
    x = rand(1500)
    y = rand(1500)
    t = Table(; x, y)
    f = Polynomial(1, 2, 3) # f(x) = 1 + 2x + 3x²
    T = Functional(f)
    n, c = apply(T, t)
    @test f.(x) == n.x
    @test f.(y) == n.y
    @test all(≥(1), n.x)
    @test all(≥(1), n.y)
    @test isrevertible(T) == false

    # apply functions to specific columns
    x = π*rand(1500)
    y = 2*(rand(1500) .- 0.5)
    z = x + y
    t = Table(; x, y, z)
    T = Functional(1 => cos, 2 => acos)
    n, c = apply(T, t)
    @test all(x -> -1 ≤ x ≤ 1, n.x)
    @test all(y -> 0 ≤ y ≤ π, n.y)
    @test t.z == n.z
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = π*rand(1500)
    y = π*(rand(1500) .- 0.5)
    z = x + y
    t = Table(; x, y, z)
    T = Functional(:x => cos, :y => sin)
    n, c = apply(T, t)
    @test all(x -> -1 ≤ x ≤ 1, n.x)
    @test all(y -> -1 ≤ y ≤ 1, n.y)
    @test t.z == n.z
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = 2*(rand(1500) .- 0.5)
    y = 2*(rand(1500) .- 0.5)
    z = x + y
    t = Table(; x, y, z)
    T = Functional("x" => acos, "y" => asin)
    n, c = apply(T, t)
    @test all(x -> 0 ≤ x ≤ π, n.x)
    @test all(y -> -π/2 ≤ y ≤ π/2, n.y)
    @test t.z == n.z
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    T = Functional(1 => cos, 2 => sin)
    @test isrevertible(T) == true
    T = Functional(:x => cos, :y => sin)
    @test isrevertible(T) == true
    T = Functional("x" => cos, "y" => sin)
    @test isrevertible(T) == true
    T = Functional(1 => abs, 2 => sin)
    @test isrevertible(T) == false
    T = Functional(:x => abs, :y => sin)
    @test isrevertible(T) == false
    T = Functional("x" => abs, "y" => sin)
    @test isrevertible(T) == false

    # row table
    x = π*rand(1500)
    y = π*rand(1500)
    t = Table(; x, y)
    rt = Tables.rowtable(t)
    T = Functional(cos)
    n, c = apply(T, rt)
    @test Tables.isrowtable(n)
    rtₒ = revert(T, n, c)
    @test Tables.matrix(rt) ≈ Tables.matrix(rtₒ)

    # throws
    @test_throws ArgumentError Functional()
    t = Table(x = rand(15), y = rand(15))
    T = Functional(Polynomial(1, 2, 3))
    n, c = apply(T, t)
    @test_throws AssertionError revert(T, n, c)
    T = Functional(:x => abs, :y => sin)
    n, c = apply(T, t)
    @test_throws AssertionError revert(T, n, c)
  end

  @testset "EigenAnalysis" begin
    # PCA test
    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
    t = Table(; x, y)
    T = EigenAnalysis(:V)
    n, c = apply(T, t)
    Σ = cov(Tables.matrix(n))
    @test Σ[1,1] > 1
    @test isapprox(Σ[1,2], 0; atol=1e-6)
    @test isapprox(Σ[2,1], 0; atol=1e-6)
    @test Σ[2,2] > 1
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    # DRS test
    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
    t = Table(; x, y)
    T = EigenAnalysis(:VD)
    n, c = apply(T, t)
    Σ = cov(Tables.matrix(n))
    @test isapprox(Σ[1,2], 0; atol=1e-6)
    @test isapprox(Σ[2,1], 0; atol=1e-6)
    @test isapprox(Σ[1,1], 1; atol=1e-6)
    @test isapprox(Σ[2,2], 1; atol=1e-6)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    # SDS test
    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
    t = Table(; x, y)
    T = EigenAnalysis(:VDV)
    n, c = apply(T, t)
    Σ = cov(Tables.matrix(n))
    @test isapprox(Σ[1,2], 0; atol=1e-6)
    @test isapprox(Σ[2,1], 0; atol=1e-6)
    @test isapprox(Σ[1,1], 1; atol=1e-6)
    @test isapprox(Σ[2,2], 1; atol=1e-6)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = rand(rng, Normal(0, 10), 4000)
    y = x + rand(rng, Normal(0, 2), 4000)
    t₁ = Table(; x, y)
    t₂, c₂ = apply(EigenAnalysis(:V), t₁)
    t₃, c₃ = apply(EigenAnalysis(:VD), t₁)
    t₄, c₄ = apply(EigenAnalysis(:VDV), t₁)
    t₅, c₅ = apply(PCA(), t₁)
    t₆, c₆ = apply(DRS(), t₁)
    t₇, c₇ = apply(SDS(), t₁)

    # visual tests    
    if visualtests
      p₁ = scatter(t₁.x, t₁.y, label="Original")
      p₂ = scatter(t₂.PC1, t₂.PC2, label="V")
      p₃ = scatter(t₃.PC1, t₃.PC2, label="VD")
      p₄ = scatter(t₄.PC1, t₄.PC2, label="VDV")
      p₅ = scatter(t₅.PC1, t₅.PC2, label="PCA")
      p₆ = scatter(t₆.PC1, t₆.PC2, label="DRS")
      p₇ = scatter(t₇.PC1, t₇.PC2, label="SDS")
      p = plot(p₁, p₂, p₃, p₄, layout=(2,2))
      q = plot(p₂, p₃, p₄, p₅, p₆, p₇, layout=(2,3))

      @test_reference joinpath(datadir, "eigenanalysis-1.png") p
      @test_reference joinpath(datadir, "eigenanalysis-2.png") q
    end

    # row table
    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
    t = Table(; x, y)
    rt = Tables.rowtable(t)
    T = EigenAnalysis(:V)
    n, c = apply(T, rt)
    @test Tables.isrowtable(n)
    rtₒ = revert(T, n, c)
    @test Tables.matrix(rt) ≈ Tables.matrix(rtₒ)

    # maxdim
    x = randn(1000)
    y = x + randn(1000)
    z = 2x - y + randn(1000)
    t = Table(; x, y, z)

    # PCA
    T = PCA(maxdim=2)
    n, c = apply(T, t)
    Σ = cov(Tables.matrix(n))
    @test Tables.columnnames(n) == (:PC1, :PC2)
    @test isapprox(Σ[1,2], 0; atol=1e-6)
    @test isapprox(Σ[2,1], 0; atol=1e-6)

    # DRS
    T = DRS(maxdim=2)
    n, c = apply(T, t)
    Σ = cov(Tables.matrix(n))
    @test Tables.columnnames(n) == (:PC1, :PC2)
    @test isapprox(Σ[1,2], 0; atol=1e-6)
    @test isapprox(Σ[2,1], 0; atol=1e-6)
    @test isapprox(Σ[1,1], 1; atol=1e-6)
    @test isapprox(Σ[2,2], 1; atol=1e-6)

    # SDS
    T = SDS(maxdim=2)
    n, c = apply(T, t)
    Σ = cov(Tables.matrix(n))
    @test Tables.columnnames(n) == (:PC1, :PC2)
    @test isapprox(Σ[1,2], 0; atol=1e-6)
    @test isapprox(Σ[2,1], 0; atol=1e-6)
    @test isapprox(Σ[1,1], 1; atol=1e-6)
    @test isapprox(Σ[2,2], 1; atol=1e-6)

    # pratio
    a = randn(rng, 1000)
    b = randn(rng, 1000)
    c = a + randn(rng, 1000)
    d = b - randn(rng, 1000)
    e = 3d + c - randn(rng, 1000)
    t = Table(; a, b, c, d, e)

    # PCA
    T = PCA(pratio=0.90)
    n, c = apply(T, t)
    Σ = cov(Tables.matrix(n))
    @test Tables.columnnames(n) == (:PC1, :PC2, :PC3)
    @test isapprox(Σ[1,2], 0; atol=1e-6)
    @test isapprox(Σ[1,3], 0; atol=1e-6)
    @test isapprox(Σ[2,1], 0; atol=1e-6)
    @test isapprox(Σ[2,3], 0; atol=1e-6)
    @test isapprox(Σ[3,1], 0; atol=1e-6)
    @test isapprox(Σ[3,2], 0; atol=1e-6)

    # DRS
    T = DRS(pratio=0.90)
    n, c = apply(T, t)
    Σ = cov(Tables.matrix(n))
    @test Tables.columnnames(n) == (:PC1, :PC2, :PC3)
    @test isapprox(Σ[1,2], 0; atol=1e-6)
    @test isapprox(Σ[1,3], 0; atol=1e-6)
    @test isapprox(Σ[2,1], 0; atol=1e-6)
    @test isapprox(Σ[2,3], 0; atol=1e-6)
    @test isapprox(Σ[3,1], 0; atol=1e-6)
    @test isapprox(Σ[3,2], 0; atol=1e-6)
    @test isapprox(Σ[1,1], 1; atol=1e-6)
    @test isapprox(Σ[2,2], 1; atol=1e-6)
    @test isapprox(Σ[3,3], 1; atol=1e-6)

    # SDS
    T = SDS(pratio=0.90)
    n, c = apply(T, t)
    Σ = cov(Tables.matrix(n))
    @test Tables.columnnames(n) == (:PC1, :PC2, :PC3)
    @test isapprox(Σ[1,2], 0; atol=1e-6)
    @test isapprox(Σ[1,3], 0; atol=1e-6)
    @test isapprox(Σ[2,1], 0; atol=1e-6)
    @test isapprox(Σ[2,3], 0; atol=1e-6)
    @test isapprox(Σ[3,1], 0; atol=1e-6)
    @test isapprox(Σ[3,2], 0; atol=1e-6)
    @test isapprox(Σ[1,1], 1; atol=1e-6)
    @test isapprox(Σ[2,2], 1; atol=1e-6)
    @test isapprox(Σ[3,3], 1; atol=1e-6)
  end

  @testset "RowTable" begin
    a = [3, 2, 1, 4, 5, 3]
    b = [1, 4, 4, 5, 8, 5]
    c = [1, 1, 6, 2, 4, 1]
    t = Table(; a, b, c)
    T = RowTable()
    n, c = apply(T, t)
    tₒ = revert(T, n, c)
    @test typeof(n) <: Vector
    @test Tables.rowaccess(n)
    @test typeof(tₒ) <: Table
  end

  @testset "ColTable" begin
    a = [3, 2, 1, 4, 5, 3]
    b = [1, 4, 4, 5, 8, 5]
    c = [1, 1, 6, 2, 4, 1]
    t = Table(; a, b, c)
    T = ColTable()
    n, c = apply(T, t)
    tₒ = revert(T, n, c)
    @test typeof(n) <: NamedTuple
    @test Tables.columnaccess(n)
    @test typeof(tₒ) <: Table
  end

  @testset "Sequential" begin
    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
    z = y + rand(Normal(0, 5), 1500)
    t = Table(; x, y, z)
    T = Scale(low=0.2, high=0.8) → EigenAnalysis(:VDV)
    n, c = apply(T, t)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
    z = y + rand(Normal(0, 5), 1500)
    t = Table(; x, y, z)
    T = Select(:x, :z) → ZScore() → EigenAnalysis(:V) → Scale(low=0, high=1)
    n, c = apply(T, t)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    # reapply with Sequential transform
    t = Table(x=rand(1000))
    T = ZScore() → Quantile()
    n1, c1 = apply(T, t)
    n2 = reapply(T, t, c1)
    @test n1 == n2

    # row table
    rt = Tables.rowtable(t)
    T = Scale(low=0.2, high=0.8) → EigenAnalysis(:VDV)
    n, c = apply(T, rt)
    @test Tables.isrowtable(n)
    rtₒ = revert(T, n, c)
    @test Tables.matrix(rt) ≈ Tables.matrix(rtₒ)
  end

  @testset "Parallel" begin
    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
    z = y + rand(Normal(0, 5), 1500)
    t = Table(; x, y, z)
    T = Scale(low=0.3, high=0.6) ⊔ EigenAnalysis(:VDV)
    n, c = apply(T, t)
    tₒ = revert(T, n, c)
    @test Tables.matrix(t) ≈ Tables.matrix(tₒ)

    # check cardinality of Parallel
    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
    z = y + rand(Normal(0, 5), 1500)
    t = Table(; x, y, z)
    T = ZScore() ⊔ EigenAnalysis(:V)
    n = T(t)
    @test length(Tables.columnnames(n)) == 6

    # distributivity with respect to Sequential
    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
    z = y + rand(Normal(0, 5), 1500)
    t = Table(; x, y, z)
    T₁ = Center()
    T₂ = Scale(low=0.2, high=0.8)
    T₃ = EigenAnalysis(:VD)
    P₁ = T₁ → (T₂ ⊔ T₃)
    P₂ = (T₁ → T₂) ⊔ (T₁ → T₃)
    n₁ = P₁(t)
    n₂ = P₂(t)
    @test Tables.matrix(n₁) ≈ Tables.matrix(n₂)

    # reapply with Parallel transform
    t = Table(x=rand(1000))
    T = ZScore() ⊔ Quantile()
    n1, c1 = apply(T, t)
    n2 = reapply(T, t, c1)
    @test n1 == n2

    # row table
    x = rand(Normal(0, 10), 1500)
    y = x + rand(Normal(0, 2), 1500)
    z = y + rand(Normal(0, 5), 1500)
    t = Table(; x, y, z)
    rt = Tables.rowtable(t)
    T = Scale(low=0.3, high=0.6) ⊔ EigenAnalysis(:VDV)
    n, c = apply(T, rt)
    @test Tables.isrowtable(n)
    rtₒ = revert(T, n, c)
    @test Tables.matrix(rt) ≈ Tables.matrix(rtₒ)

    # https://github.com/JuliaML/TableTransforms.jl/issues/80
    t = (a=rand(3), b=rand(3))
    T = Select(:a) ⊔ Select(:b)
    n, c = apply(T, t)
    @test t == n
    tₒ = revert(T, n, c)
    @test tₒ == t
  end
end

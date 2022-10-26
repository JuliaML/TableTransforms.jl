@testset "Selection" begin
  @testset "TableSelection" begin
    a = rand(10)
    b = rand(10)
    c = rand(10)
    d = rand(10)
    e = rand(10)
    f = rand(10)
    t = Table(; a, b, c, d, e, f)
  
    # Tables.jl interface
    select = [:a, :b, :e]
    newnames = select
    s = TableTransforms.TableSelection(t, newnames, select)
    @test Tables.istable(s)      == true
    @test Tables.columnaccess(s) == true
    @test Tables.rowaccess(s)    == true
    @test Tables.columns(s)      === s
    @test Tables.rows(s)         == TableTransforms.SelectionRows(s)
    @test Tables.columnnames(s)  == [:a, :b, :e]
    @test Tables.schema(s).names == (:a, :b, :e)
    @test Tables.schema(s).types == (Float64, Float64, Float64)
    @test Tables.materializer(s) == Tables.materializer(t)
  
    # getcolumn
    cols = Tables.columns(t)
    @test Tables.getcolumn(s, :a) == Tables.getcolumn(cols, :a)
    @test Tables.getcolumn(s, 1)  == Tables.getcolumn(cols, 1)
    @test Tables.getcolumn(s, 3)  == Tables.getcolumn(cols, :e)
  
    # selectin with renaming
    select = [:c, :d, :f]
    newnames = [:x, :y, :z]
    s = TableTransforms.TableSelection(t, newnames, select)
    @test Tables.columnnames(s)   == [:x, :y, :z]
    @test Tables.getcolumn(s, :x) == t.c
    @test Tables.getcolumn(s, :y) == t.d
    @test Tables.getcolumn(s, :z) == t.f
    @test Tables.getcolumn(s, 1)  == t.c
    @test Tables.getcolumn(s, 2)  == t.d
    @test Tables.getcolumn(s, 3)  == t.f
  
    # row table
    select = [:a, :b, :e]
    newnames = select
    rt = Tables.rowtable(t)
    s = TableTransforms.TableSelection(rt, newnames, select)
    cols = Tables.columns(rt)
    @test Tables.getcolumn(s, :a) == Tables.getcolumn(cols, :a)
    @test Tables.getcolumn(s, 1)  == Tables.getcolumn(cols, 1)
    @test Tables.getcolumn(s, 3)  == Tables.getcolumn(cols, :e)
  
    # throws
    @test_throws AssertionError TableTransforms.TableSelection(t, [:a, :b, :z], [:a, :b, :z])
    @test_throws AssertionError TableTransforms.TableSelection(t, [:x, :y, :z], [:c, :d, :k])
    s = TableTransforms.TableSelection(t, [:a, :b, :e], [:a, :b, :e])
    @test_throws ErrorException Tables.getcolumn(s, :f)
    @test_throws ErrorException Tables.getcolumn(s, 4)
    s = TableTransforms.TableSelection(t, [:x, :y, :z], [:c, :d, :f])
    @test_throws ErrorException Tables.getcolumn(s, :c)
    @test_throws ErrorException Tables.getcolumn(s, 4)
    @test_throws ErrorException Tables.getcolumn(s, -2)
  end

  @testset "SelectionRow" begin
    x = [2, 1, 7, 5, 2]
    y = [7, 6, 8, 1, 3]
    z = [3, 4, 6, 4, 7]
    table = Table(; x, y, z)

    select = [:x, :z]
    newnames = select
    s = TableTransforms.TableSelection(table, newnames, select)
    m = Tables.matrix(s)

    # Tables.jl row interface
    srow = TableTransforms.SelectionRow(s, 1)
    @test Tables.columnnames(srow)   == Tables.columnnames(s)
    @test Tables.getcolumn(srow, 1)  == 2
    @test Tables.getcolumn(srow, 2)  == 3
    @test Tables.getcolumn(srow, :x) == 2
    @test Tables.getcolumn(srow, :z) == 3

    # Iteration interface
    for (i, row) in enumerate(eachrow(m))
      srow = TableTransforms.SelectionRow(s, i)
      @test length(srow)  == length(row)
      @test collect(srow) == collect(row)
      for (sr, r) in zip(srow, row)
        @test sr == r
      end
    end

    # Indexing interface
    for (i, row) in enumerate(eachrow(m))
      srow = TableTransforms.SelectionRow(s, i)
      @test firstindex(srow) == 1
      @test lastindex(srow)  == lastindex(row)
      for j in eachindex(srow)
        @test srow[j] == row[j]
      end
    end
  end

  @testset "SelectionRows" begin
    a = rand(10)
    b = rand(10)
    c = rand(10)
    d = rand(10)
    t = Table(; a, b, c, d)

    select = [:a, :d]
    newnames = select
    s = TableTransforms.TableSelection(t, newnames, select)
    srows = TableTransforms.SelectionRows(s)

    # Tables.jl interface
    @test Tables.istable(srows)       == true
    @test Tables.rowaccess(srows)     == true
    @test Tables.columnaccess(srows)  == true
    @test Tables.rows(srows)          === srows
    @test Tables.columns(srows)       === Tables.columns(srows.selection)
    @test Tables.columnnames(srows)   == Tables.columnnames(srows.selection)
    @test Tables.schema(srows)        == Tables.schema(srows.selection)
    @test Tables.materializer(srows)  == Tables.materializer(srows.selection)

    # getcolumn
    cols = Tables.columns(srows)
    @test Tables.getcolumn(srows, :a) == Tables.getcolumn(cols, :a)
    @test Tables.getcolumn(srows, 1)  == Tables.getcolumn(cols, 1)
    @test Tables.getcolumn(srows, 2)  == Tables.getcolumn(cols, :d)

    # Iteration interface
    @test length(srows) == TableTransforms._nrows(s.cols)
    @test eltype(srows) == typeof(TableTransforms.SelectionRow(s, 1))
    for (i, srow) in enumerate(srows)
      @test srow == TableTransforms.SelectionRow(s, i)
    end

    # Indexing interface
    @test firstindex(srows) == 1
    @test lastindex(srows)  == TableTransforms._nrows(s.cols)
    for i in eachindex(srows)
      @test srows[i] == TableTransforms.SelectionRow(s, i)
    end
  end
end

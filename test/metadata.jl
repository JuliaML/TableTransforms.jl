@testset "Metadata" begin
  @testset "ConstMeta" begin
    a = rand(10)
    b = rand(10)
    c = rand(10)
    d = rand(10)
    t = Table(; a, b, c, d)
    m = ConstMeta(fill(1, 10))
    mt = MetaTable(t, m)

    T = Select(1, 3)
    mn, mc = apply(T, mt)
    tn, tc = apply(T, t)
    @test mn.meta == m
    @test mn.table == tn
    mtₒ = revert(T, mn, mc)
    @test mtₒ == mt

    T = Rename(:a => :x, :c => :y)
    mn, mc = apply(T, mt)
    tn, tc = apply(T, t)
    @test mn.meta == m
    @test mn.table == tn
    mtₒ = revert(T, mn, mc)
    @test mtₒ == mt

    T = Functional(sin)
    mn, mc = apply(T, mt)
    tn, tc = apply(T, t)
    @test mn.meta == m
    @test mn.table == tn
    mtₒ = revert(T, mn, mc)
    @test mtₒ.meta == mt.meta
    @test Tables.matrix(mtₒ.table) ≈ Tables.matrix(mt.table)
  end

  @testset "VarMeta" begin
    a = rand(10)
    b = rand(10)
    c = rand(10)
    d = rand(10)
    t = Table(; a, b, c, d)
    m = VarMeta(fill(1, 10))
    mt = MetaTable(t, m)

    T = Reject(1, 3)
    mn, mc = apply(T, mt)
    tn, tc = apply(T, t)
    @test mn.meta == VarMeta(m.data .+ 2)
    @test mn.table == tn
    mtₒ = revert(T, mn, mc)
    @test mtₒ == mt

    T = Rename(:b => :x, :d => :y)
    mn, mc = apply(T, mt)
    tn, tc = apply(T, t)
    @test mn.meta == VarMeta(m.data .+ 2)
    @test mn.table == tn
    mtₒ = revert(T, mn, mc)
    @test mtₒ == mt

    T = Functional(cos)
    mn, mc = apply(T, mt)
    tn, tc = apply(T, t)
    @test mn.meta == VarMeta(m.data .+ 2)
    @test mn.table == tn
    mtₒ = revert(T, mn, mc)
    @test mtₒ.meta == mt.meta
    @test Tables.matrix(mtₒ.table) ≈ Tables.matrix(mt.table)
  end
end

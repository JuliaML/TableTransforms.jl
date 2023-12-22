@testset "Quantile" begin
  @test TT.parameters(Quantile()) == (; dist=Normal())

  t = Table(z=rand(100))
  T = Quantile()
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  @test all(-4 .< extrema(n.z) .< 4)
  @test all(0 .≤ extrema(tₒ.z) .≤ 1)

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

  # colspec
  x = fill(3.0, 100)
  y = rand(100)
  z = rand(100)
  t = Table(; x, y, z)

  T = Quantile(1, 2)
  n, c = apply(T, t)
  @test maximum(abs, n.x - x) < 0.1
  @test n.y != y
  tₒ = revert(T, n, c)
  @test tₒ.x == t.x

  T = Quantile([:z])
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  @test all(-4 .< extrema(n.z) .< 4)
  @test all(0 .≤ extrema(tₒ.z) .≤ 1)

  T = Quantile(("x", "y"))
  n, c = apply(T, t)
  @test maximum(abs, n.x - x) < 0.1
  @test n.y != y
  tₒ = revert(T, n, c)
  @test tₒ.x == t.x

  T = Quantile(r"z")
  n, c = apply(T, t)
  tₒ = revert(T, n, c)
  @test all(-4 .< extrema(n.z) .< 4)
  @test all(0 .≤ extrema(tₒ.z) .≤ 1)

  # smooth repeated values
  x = readdlm(joinpath(datadir, "quantile.dat"))
  t = (; x=vec(x))
  n = t |> Quantile()

  if visualtests
    # visualize histogram and theoretical pdf
    fig = Mke.Figure(size=(800, 800))
    Mke.hist(fig[1, 1], n.x, normalization=:pdf)
    Mke.plot!(fig[1, 1], Normal())
    @test_reference joinpath(datadir, "quantile.png") fig
  end
end

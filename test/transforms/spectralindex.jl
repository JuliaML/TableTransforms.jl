@testset "SpectralIndex" begin
  @test !isrevertible(SpectralIndex("NDVI"))

  # standard names
  t = Table(R=[1, 2, 3], N=[4, 5, 6])
  T = SpectralIndex("NDVI")
  @test T(t).NDVI ≈ [0.6, 0.42857142857142855, 0.3333333333333333]
  T = SpectralIndex("NDVI", R="R")
  @test T(t).NDVI ≈ [0.6, 0.42857142857142855, 0.3333333333333333]
  T = SpectralIndex("NDVI", N="N")
  @test T(t).NDVI ≈ [0.6, 0.42857142857142855, 0.3333333333333333]
  T = SpectralIndex("NDVI", R="R", N="N")
  @test T(t).NDVI ≈ [0.6, 0.42857142857142855, 0.3333333333333333]

  # some non-standard names
  t = Table(R=[1, 2, 3], NIR=[4, 5, 6])
  T = SpectralIndex("NDVI", N="NIR")
  @test T(t).NDVI ≈ [0.6, 0.42857142857142855, 0.3333333333333333]
  T = SpectralIndex("NDVI")
  @test_throws ArgumentError T(t)
  T = SpectralIndex("NDVI", R="RED")
  @test_throws ArgumentError T(t)

  # all non-standard names
  t = Table(RED=[1, 2, 3], NIR=[4, 5, 6])
  T = SpectralIndex("NDVI", R="RED", N="NIR")
  @test T(t).NDVI ≈ [0.6, 0.42857142857142855, 0.3333333333333333]
  T = SpectralIndex("NDVI", R="RED")
  @test_throws ArgumentError T(t)
  T = SpectralIndex("NDVI", N="NIR")
  @test_throws ArgumentError T(t)

  # bands as symbols
  t = Table(RED=[1, 2, 3], NIR=[4, 5, 6])
  T = SpectralIndex("NDVI", R=:RED, N=:NIR)
  @test T(t).NDVI ≈ [0.6, 0.42857142857142855, 0.3333333333333333]

  # auxiliary functions
  @test spectralindices() isa Dict
  @test spectralbands("NDVI") isa Vector
end

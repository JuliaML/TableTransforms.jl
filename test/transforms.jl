transformfiles = [
  "select.jl",
  "rename.jl",
  "stdnames.jl",
  "sort.jl",
  "sample.jl",
  "filter.jl",
  "replace.jl",
  "coalesce.jl",
  "coerce.jl",
  "levels.jl",
  "onehot.jl",
  "identity.jl",
  "center.jl",
  "scale.jl",
  "zscore.jl",
  "quantile.jl",
  "functional.jl",
  "eigenanalysis.jl",
  "rowtable.jl",
  "coltable.jl",
  "sequential.jl",
  "parallel.jl"
]

@testset "Transforms" begin
  # using MersenneTwister for backward
  # compatibility with old Julia versions
  rng = MersenneTwister(42)

  for transformfile in transformfiles
    include("transforms/$transformfile")
  end
end

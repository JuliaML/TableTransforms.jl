transformfiles = [
  "select.jl",
  "rename.jl",
  "stdnames.jl",
  "sort.jl",
  "sample.jl",
  "filter.jl",
  "map.jl",
  "replace.jl",
  "coalesce.jl",
  "coerce.jl",
  "levels.jl",
  "indicator.jl",
  "onehot.jl",
  "identity.jl",
  "center.jl",
  "scale.jl",
  "zscore.jl",
  "quantile.jl",
  "functional.jl",
  "eigenanalysis.jl",
  "projectionpursuit.jl",
  "rowtable.jl",
  "coltable.jl",
  "sequential.jl",
  "parallel.jl"
]

@testset "Transforms" begin
  for transformfile in transformfiles
    println("Testing $transformfile...")
    include("transforms/$transformfile")
  end
end

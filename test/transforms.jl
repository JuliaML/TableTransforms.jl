transformfiles = [
  "select.jl",
  "rename.jl",
  "only.jl",
  "stdnames.jl",
  "sort.jl",
  "sample.jl",
  "filter.jl",
  "dropmissing.jl",
  "dropextrema.jl",
  "dropunits.jl",
  "absoluteunits.jl",
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
  "closure.jl",
  "remainder.jl",
  "logratio.jl",
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

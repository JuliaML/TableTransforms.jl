transformfiles = [
  "scitypeassertion.jl",
  "select.jl",
  "rename.jl",
  "satisfies.jl",
  "stdnames.jl",
  "stdfeats.jl",
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
  "compose.jl",
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

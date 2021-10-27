using TableTransforms
using Distributions
using Test

# list of tests
testfiles = [
  "distributions.jl"
]

@testset "TableTransforms.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end
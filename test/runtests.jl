using TableTransforms
using Distributions
using Test
using Tables
using Statistics
using LinearAlgebra

# list of tests
testfiles = [
  "distributions.jl",
  "transforms.jl"
]

@testset "TableTransforms.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end
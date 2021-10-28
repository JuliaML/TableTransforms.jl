using TableTransforms
using Distributions
using Tables
using LinearAlgebra
using Statistics
using DataFrames
using Test, Random, Plots
using ReferenceTests, ImageIO

# environment settings
isCI = "CI" ∈ keys(ENV)
islinux = Sys.islinux()
visualtests = !isCI || (isCI && islinux)
datadir = joinpath(@__DIR__,"data")

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
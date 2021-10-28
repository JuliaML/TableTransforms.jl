using TableTransforms
using Distributions
using Tables
using DataFrames
using LinearAlgebra
using Statistics
using Test, Random, Plots
using ReferenceTests, ImageIO

# set default configurations for plots
gr(ms=2, mc=:black, label=false, aspect_ratio=:equal, markersize=0.7, size=(600,400))

# workaround GR warnings
ENV["GKSwstype"] = "100"

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
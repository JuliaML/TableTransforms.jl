using TableTransforms
using Distributions
using Tables
using Unitful
using TypedTables
using CategoricalArrays
using ScientificTypes: Continuous, Count, Finite, Multiclass
using LinearAlgebra
using Statistics
using Test, Random, Plots
using ReferenceTests, ImageIO
using StatsBase
using PairPlots
import ColumnSelectors as CS

const TT = TableTransforms

# set default configurations for plots
gr(ms=1, mc=:black, label=false, size=(600, 400))

# workaround GR warnings
ENV["GKSwstype"] = "100"

# environment settings
isCI = "CI" ∈ keys(ENV)
islinux = Sys.islinux()
visualtests = !isCI || (isCI && islinux)
datadir = joinpath(@__DIR__, "data")

# using MersenneTwister for backward
# compatibility with old Julia versions
rng = MersenneTwister(42)

# for functor tests in Functional testset
struct Polynomial{T<:Real}
  coeffs::Vector{T}
end
Polynomial(args::T...) where {T<:Real} = Polynomial(collect(args))
(p::Polynomial)(x) = sum(a * x^(i - 1) for (i, a) in enumerate(p.coeffs))

include("metatable.jl")

# list of tests
testfiles =
  ["distributions.jl", "assertions.jl", "transforms.jl", "metadata.jl", "tableselection.jl", "tablerows.jl", "shows.jl"]

@testset "TableTransforms.jl" begin
  for testfile in testfiles
    println("Testing $testfile...")
    include(testfile)
  end
end

using TableTransforms
using CoDa
using Tables
using Unitful
using TypedTables
using CategoricalArrays
using LinearAlgebra
using Distributions
using StatsBase
using Statistics
using DelimitedFiles
using ReferenceTests
using StableRNGs
using PairPlots
using ImageIO
using Test

import CairoMakie as Mke
import ColumnSelectors as CS
import DataScienceTraits as DST

const TT = TableTransforms

# set default configurations for plots
Mke.activate!(type="png")

# environment settings
isCI = "CI" ∈ keys(ENV)
islinux = Sys.islinux()
visualtests = !isCI || (isCI && islinux)
datadir = joinpath(@__DIR__, "data")

# using StableRNG for compatibility between Julia versions
rng = StableRNG(42)

# for functor tests in Functional testset
struct Polynomial{T<:Real}
  coeffs::Vector{T}
end
Polynomial(args::T...) where {T<:Real} = Polynomial(collect(args))
(p::Polynomial)(x) = sum(a * x^(i - 1) for (i, a) in enumerate(p.coeffs))

include("metatable.jl")

# list of tests
testfiles = ["distributions.jl", "tableselection.jl", "tablerows.jl", "transforms.jl", "metadata.jl", "shows.jl"]

@testset "TableTransforms.jl" begin
  for testfile in testfiles
    println("Testing $testfile...")
    include(testfile)
  end
end

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module TableTransforms

# Transforms API
import TransformsAPI: Transform
import TransformsAPI: assertions, isrevertible, preprocess
import TransformsAPI: apply, revert, reapply

using Tables
using ScientificTypes
using Distributions: Normal
using Transducers: tcollect
using StatsBase: AbstractWeights
using StatsBase: Weights, sample
using LinearAlgebra
using Statistics
using PrettyTables
using AbstractTrees
using CategoricalArrays
using Random
using Optim: optimize, minimizer

import Distributions: ContinuousUnivariateDistribution
import Distributions: quantile, cdf

include("tabletraits.jl")
include("assertions.jl")
include("distributions.jl")
include("colspec.jl")
include("transforms.jl")

export
  # interface
  isrevertible,
  apply,
  revert,
  reapply,

  # built-in
  Select,
  Reject,
  Rename,
  StdNames,
  Sort,
  Sample,
  Filter,
  DropMissing,
  Replace,
  Coalesce,
  Coerce,
  Levels,
  OneHot,
  Identity,
  Center,
  Scale,
  MinMax,
  Interquartile,
  ZScore,
  Quantile,
  Functional,
  EigenAnalysis,
  PCA, DRS, SDS,
  ProjectionPursuit,
  RowTable,
  ColTable,
  Sequential,
  Parallel,
  →, ⊔
end

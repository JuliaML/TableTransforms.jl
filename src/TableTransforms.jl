# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module TableTransforms

using Tables
using ScientificTypes
using Distributions: Normal
using Transducers: tcollect
using StatsBase: Weights, sample
using LinearAlgebra
using Statistics
using PrettyTables
using AbstractTrees
using CategoricalArrays
using Random

import Distributions: ContinuousUnivariateDistribution
import Distributions: quantile, cdf

include("assertions.jl")
include("distributions.jl")
include("colspec.jl")
include("transforms.jl")

export
  # interface
  isrevertible,
  apply, revert, reapply,

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
  RowTable,
  ColTable,
  Sequential,
  Parallel,
  →, ⊔
end

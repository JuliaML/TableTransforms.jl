# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module TableTransforms

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
using NelderMead: optimise

import Distributions: ContinuousUnivariateDistribution
import Distributions: quantile, cdf

import TransformsBase: Transform, Identity, →
import TransformsBase: assertions, isrevertible, preprocess
import TransformsBase: apply, revert, reapply

include("colspec.jl")
include("assertions.jl")
include("tabletraits.jl")
include("distributions.jl")
include("tableselection.jl")
include("tablerows.jl")
include("transforms.jl")

export
  # abstract types
  TableTransform,
  FeatureTransform,

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
  Map,
  Replace,
  Coalesce,
  Coerce,
  Levels,
  Indicator,
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
  PCA,
  DRS,
  SDS,
  ProjectionPursuit,
  RowTable,
  ColTable,
  →,
  ⊔
end

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module TableTransforms

using Tables
using Unitful
using Statistics
using PrettyTables
using AbstractTrees
using LinearAlgebra
using DataScienceTraits
using CategoricalArrays
using Random

using TransformsBase: Transform, Identity, →
using DataScienceTraits: SciType, Continuous, coerce
using ColumnSelectors: ColumnSelector, SingleColumnSelector
using ColumnSelectors: AllSelector, Column, selector, selectsingle
using Unitful: AbstractQuantity, AffineQuantity, AffineUnits, Units
using Distributions: ContinuousUnivariateDistribution, Normal
using StatsBase: AbstractWeights, Weights, sample
using Transducers: tcollect
using NelderMead: optimise

import Distributions: quantile, cdf
import TransformsBase: assertions, isrevertible, preprocess
import TransformsBase: apply, revert, reapply

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
  DropExtrema,
  DropUnits,
  AbsoluteUnits,
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
  Closure,
  Remainder,
  RowTable,
  ColTable,
  →,
  ⊔

end

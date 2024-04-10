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
using CoDa

using TransformsBase: Transform, Identity, →
using ColumnSelectors: ColumnSelector, SingleColumnSelector
using ColumnSelectors: AllSelector, Column, selector, selectsingle
using DataScienceTraits: SciType, Continuous, Categorical, coerce
using Unitful: AbstractQuantity, AffineQuantity, AffineUnits, Units
using Distributions: ContinuousUnivariateDistribution, Normal
using InverseFunctions: NoInverse, inverse as invfun
using StatsBase: AbstractWeights, Weights, sample
using Transducers: tcollect
using NelderMead: optimise

import Distributions: quantile, cdf
import TransformsBase: assertions, parameters, isrevertible, isinvertible
import TransformsBase: apply, revert, reapply, preprocess, inverse

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
  Assert,
  Select,
  Reject,
  Satisfies,
  Only,
  Except,
  DropConstant,
  Rename,
  StdNames,
  StdFeats,
  Sort,
  Sample,
  Filter,
  DropMissing,
  DropNaN,
  DropExtrema,
  DropUnits,
  AbsoluteUnits,
  Unitify,
  Map,
  Replace,
  Coalesce,
  Coerce,
  Levels,
  Indicator,
  OneHot,
  Identity,
  Center,
  LowHigh,
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
  Compose,
  ALR,
  CLR,
  ILR,
  RowTable,
  ColTable,
  →,
  ⊔

end

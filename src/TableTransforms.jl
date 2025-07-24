# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module TableTransforms

using Tables
using Unitful
using PrettyTables
using AbstractTrees
using TableDistances
using DataScienceTraits
using CategoricalArrays
using LinearAlgebra
using Statistics
using Random
using CoDa

using DataScienceTraits: SciType, coerce
using TransformsBase: Transform, Identity, →
using ColumnSelectors: ColumnSelector, SingleColumnSelector
using ColumnSelectors: AllSelector, Column, selector, selectsingle
using Unitful: AbstractQuantity, AffineQuantity, AffineUnits, Units
using Distributions: ContinuousUnivariateDistribution, Normal
using InverseFunctions: NoInverse, inverse as invfun
using StatsBase: AbstractWeights, Weights, sample
using Distributed: CachingPool, pmap, workers
using SpectralIndices: indices, bands, compute
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
  isinvertible,
  apply,
  revert,
  reapply,
  inverse,

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
  Unit,
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
  SpectralIndex,
  KMedoids,
  Closure,
  Remainder,
  Compose,
  ALR,
  CLR,
  ILR,
  RowTable,
  ColTable,
  →,
  ⊔,

  # utilities
  spectralindices,
  spectralbands

end

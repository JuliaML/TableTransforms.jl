# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module TableTransforms

using Tables
using ScientificTypes
using Distributions: Normal
using Transducers: Map, foldxt
using LinearAlgebra
using Statistics

import Distributions: ContinuousUnivariateDistribution
import Distributions: quantile, cdf

include("utils.jl")
include("distributions.jl")
include("transforms.jl")

export
  # interface
  Transform,
  isrevertible,
  apply, revert,

  # built-in
  Select,
  Reject,
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
  Sequential,
  Parallel,
  →, ∥

end

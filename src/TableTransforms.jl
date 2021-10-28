# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module TableTransforms

using Tables
using ScientificTypes
using Distributions: Normal
using Statistics
using LinearAlgebra

import Distributions: ContinuousUnivariateDistribution
import Distributions: quantile, cdf

include("distributions.jl")
include("transforms.jl")

export
  # interface
  Transform,
  isrevertible,
  apply, revert,

  # built-in
  Identity,
  Center,
  Scaling,
  MinMax,
  Interquartile,
  ZScore,
  Quantile,
  Functional,
  PCA,
  Sequential,
  Parallel,
  →, ∥

end

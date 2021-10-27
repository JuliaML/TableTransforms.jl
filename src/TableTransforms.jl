# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module TableTransforms

using Tables
using ScientificTypes
using Distributions: Normal
using Statistics

import Distributions: ContinuousUnivariateDistribution
import Distributions: quantile, cdf

include("distributions.jl")
include("transforms.jl")

export
  # interface
  Transform,
  isinvertible,
  forward,
  backward,

  # built-in
  Identity,
  Scaling,
  MinMax,
  Interquartile,
  ZScore,
  Quantile,
  Functional,
  Sequential,
  →

end

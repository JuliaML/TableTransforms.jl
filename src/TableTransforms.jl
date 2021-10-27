# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module TableTransforms

using Tables
using ScientificTypes
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
  ZScore,
  Sequential,
  →

end

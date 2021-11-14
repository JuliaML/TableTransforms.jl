# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module TableTransforms

using Tables
using ScientificTypes
using Distributions: Normal
using Transducers: tcollect, push!!
using LinearAlgebra
using Statistics

import Distributions: ContinuousUnivariateDistribution
import Distributions: quantile, cdf

include("assertions.jl")
include("distributions.jl")
include("transforms.jl")

export
  # interface
  Transform,
  Stateless,
  Colwise,
  assertions,
  isrevertible,
  apply, revert, reapply,
  colapply, colrevert,

  # built-in
  Identity,
  Select,
  Reject,
  Rename3,
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
  →, ⊔

end

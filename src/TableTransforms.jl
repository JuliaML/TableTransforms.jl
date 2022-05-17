# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module TableTransforms

using Tables
using ScientificTypes
using Distributions: Normal
using Transducers: tcollect
using LinearAlgebra
using Statistics
using PrettyTables

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
  Filter,
  DropMissing,
  Rename,
  StdNames,
  Replace,
  Coalesce,
  Coerce,
  RowTable,
  ColTable,
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
  →, ⊔

end

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module TableTransforms

using Tables
using ScientificTypes
using Statistics

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

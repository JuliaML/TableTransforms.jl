# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Sequential(transforms)

A transform where `transforms` are applied in sequence.
"""
struct Sequential <: Transform
  transforms::Vector{Transform}
end

isinvertible(s::Sequential) = all(isinvertible, s.transforms)

function forward(s::Sequential, table)
  allcache = []
  current  = table
  for transform in s.transforms
    current, cache = forward(transform, current)
    push!(allcache, cache)
  end
  current, allcache
end

function backward(s::Sequential, newtable, cache)
  current = newtable
  for transform in reverse(s.transforms)
    current = backward(transform, current, pop!(cache))
  end
  current
end

→(t1, t2) = Sequential([t1, t2])
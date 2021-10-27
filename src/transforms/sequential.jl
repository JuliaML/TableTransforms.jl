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

isrevertible(s::Sequential) = all(isrevertible, s.transforms)

function apply(s::Sequential, table)
  allcache = []
  current  = table
  for transform in s.transforms
    current, cache = apply(transform, current)
    push!(allcache, cache)
  end
  current, allcache
end

function revert(s::Sequential, newtable, cache)
  current = newtable
  for transform in reverse(s.transforms)
    current = revert(transform, current, pop!(cache))
  end
  current
end

"""
    transform₁ → transform₂ → ⋯ → transformₙ

Create a [`Sequential`](@ref) transform with
`[transform₁, transform₂, …, transformₙ]`.
"""
→(t1, t2) = Sequential([t1, t2])
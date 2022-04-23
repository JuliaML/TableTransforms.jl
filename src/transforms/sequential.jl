# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Sequential(transforms)

A transform where `transforms` are applied in sequence.

# Examples

```julia
Scale(low=0.2, high=0.8) → EigenAnalysis(:VDV)
Select(:x, :z) → ZScore() → EigenAnalysis(:V) → Scale(low=0, high=1)
```
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
  allcache = deepcopy(cache)
  current  = newtable
  for transform in reverse(s.transforms)
    current = revert(transform, current, pop!(allcache))
  end
  current
end

function reapply(s::Sequential, table, cache)
  # basic checks
  ntrans = length(s.transforms)
  ncache = length(cache)
  @assert ntrans == ncache "invalid cache for transform"

  current = table
  for (ctransform, ccache) in zip(s.transforms, cache)
    current = reapply(ctransform, current, ccache)
  end
  current
end

"""
    transform₁ → transform₂ → ⋯ → transformₙ

Create a [`Sequential`](@ref) transform with
`[transform₁, transform₂, …, transformₙ]`.
"""
→(t1::Transform, t2::Transform)   = Sequential([t1, t2])
→(t1::Transform, t2::Sequential)  = Sequential([t1; t2.transforms])
→(t1::Sequential, t2::Transform)  = Sequential([t1.transforms; t2])
→(t1::Sequential, t2::Sequential) = Sequential([t1.transforms; t2.transforms])
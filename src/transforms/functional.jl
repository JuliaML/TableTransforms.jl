# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Functional(function)

The transform that applies a `function` elementwise.
"""
struct Functional{F} <: Colwise
  func::F
end

isrevertible(transform::Functional) =
  !isnothing(inverse(transform.func))

# known invertible functions
inverse(::typeof(log))  = exp
inverse(::typeof(exp))  = log
inverse(::typeof(cos))  = acos
inverse(::typeof(acos)) = cos
inverse(::typeof(sin))  = asin
inverse(::typeof(asin)) = sin

# fallback to nothing
inverse(::Any) = nothing

colcache(::Functional, x) = nothing

function colapply(transform::Functional, x, c)
  f = transform.func
  f.(x)
end

function colrevert(transform::Functional, y, c)
  g = inverse(transform.func)
  g.(y)
end
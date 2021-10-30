# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Functional(function)

The transform that applies a `function` elementwise.
"""
struct Functional <: Stateless
  func::Function
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
inverse(::Function) = nothing

function apply(transform::Functional, table)
  f = transform.func
  colwise(table) do x
    f.(x), nothing
  end
end

function revert(transform::Functional, newtable, cache)
  f = inverse(transform.func)
  colwise(newtable) do x
    f.(x), nothing
  end |> first
end
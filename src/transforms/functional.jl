# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Functional(function)

The transform that applies a `function` elementwise.
"""
struct Functional <: Transform
  func::Function
end

isinvertible(transform::Functional) =
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

function forward(transform::Functional, table)
  f = transform.func
  X = Tables.matrix(table)
  Y = f.(X)

  # table with transformed columns
  n = Tables.columnnames(table)
  𝒯 = (; zip(n, eachcol(Y))...)
  newtable = 𝒯 |> Tables.materializer(table)

  newtable, nothing
end

function backward(transform::Functional, newtable, cache)
  g = inverse(transform.func)
  Y = Tables.matrix(newtable)
  X = g.(Y)

  # table with original columns
  n = Tables.columnnames(newtable)
  𝒯 = (; zip(n, eachcol(X))...)
  𝒯 |> Tables.materializer(newtable)
end
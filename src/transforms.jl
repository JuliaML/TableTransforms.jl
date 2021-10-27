# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Transform

A transform that takes a table as input and produces a new table.
Any transform implementing the `Transform` trait should implement the
[`forward`](@ref) function. If the transform [`isinvertible`](@ref),
then it should also implement the [`backward`](@ref) function.

A functor interface is automatically generated from the functions
above, which means that any transform implementing the `Transform`
trait can be evaluated directly at any table implementing the
[Tables.jl](https://github.com/JuliaData/Tables.jl) interface.
"""
abstract type Transform end

"""
    isinvertible(transform)

Tells whether or not the `transform` is invertible, i.e. supports a
[`backward`](@ref) evaluation. Defaults to `false` for new types.
"""
isinvertible(transform) = isinvertible(typeof(transform))
isinvertible(::Type{Transform}) = false

"""
    newtable, cache = forward(transform, table)

Apply the `transform` in the forward direction on the `table`.
Return the new table and a cache, which is often set to `nothing`.
"""
function forward end

"""
    table = backward(transform, newtable, cache)

Apply the `transform` in the backward direction on the `newtable` using
a `cache` from the [`forward`](@ref) evaluation. Return the original table.
Only defined when the transform [`isinvertible`](@ref).
"""
function backward end

# ------------------------
# AUTOMATICALLY GENERATED
# ------------------------

(transform::Transform)(table) =
  forward(transform, table) |> first

# ----------------
# IMPLEMENTATIONS
# ----------------

include("transforms/identity.jl")
include("transforms/scaling.jl")
include("transforms/zscore.jl")
include("transforms/quantile.jl")
include("transforms/functional.jl")
include("transforms/sequential.jl")
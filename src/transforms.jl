# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Transform

A transform that takes a table as input and produces a new table.
Any transform implementing the `Transform` trait should implement the
[`apply`](@ref) function. If the transform [`isrevertible`](@ref),
then it should also implement the [`revert`](@ref) function.

A functor interface is automatically generated from the functions
above, which means that any transform implementing the `Transform`
trait can be evaluated directly at any table implementing the
[Tables.jl](https://github.com/JuliaData/Tables.jl) interface.
"""
abstract type Transform end

"""
    isrevertible(transform)

Tells whether or not the `transform` is revertible, i.e. supports a
[`revert`](@ref) function. Defaults to `false` for new types.
"""
isrevertible(transform) = isrevertible(typeof(transform))
isrevertible(::Type{Transform}) = false

"""
    newtable, cache = apply(transform, table)

Apply the `transform` on the `table`. Return the new table and a cache,
which can be (and sometimes is) set to `nothing`.
"""
function apply end

"""
    table = revert(transform, newtable, cache)

Revert the `transform` on the `newtable` using the `cache` from the
corresponding [`apply`](@ref) call. Return the original table. Only
defined when the transform [`isrevertible`](@ref).
"""
function revert end

# ------------------------
# AUTOMATICALLY GENERATED
# ------------------------

(transform::Transform)(table) = apply(transform, table) |> first

# ----------------
# IMPLEMENTATIONS
# ----------------

include("transforms/identity.jl")
include("transforms/scaling.jl")
include("transforms/zscore.jl")
include("transforms/quantile.jl")
include("transforms/functional.jl")
include("transforms/sequential.jl")
include("transforms/parallel.jl")
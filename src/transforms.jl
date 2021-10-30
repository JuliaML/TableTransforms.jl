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
    transform(table)

Automatically generated functor interface that calls [`apply`](@ref)
with `transform` and `table`. New types don't need to implement this.
"""
(transform::Transform)(table) = apply(transform, table) |> first

"""
    isrevertible(transform)

Tells whether or not the `transform` is revertible, i.e. supports a
[`revert`](@ref) function. Defaults to `false` for new types.
"""
isrevertible(transform) = isrevertible(typeof(transform))
isrevertible(::Type{Transform}) = false

"""
    newtable, cache = apply(transform, table)

Apply the `transform` on the `table`. Return the `newtable` and a
`cache` to revert the transform later.
"""
function apply end

"""
    table = revert(transform, newtable, cache)

Revert the `transform` on the `newtable` using the `cache` from the
corresponding [`apply`](@ref) call and return the original `table`.
Only defined when the `transform` [`isrevertible`](@ref).
"""
function revert end

"""
    Stateless

A stateless transform, i.e. a transform for which the `cache` is not
a function of the input `table` used in a previous [`apply`](@ref) call.
This trait is useful to signal that we can [`reapply`](@ref) a transform
"fitted" with training data to "test" data without relying on the `cache`.
"""
abstract type Stateless <: Transform end

"""
    reapply(transform, table, cache)

Reapply the `transform` to (a possibly different) `table` using a `cache`
that was created with a previous [`apply`](@ref) call.
"""
reapply(transform::Stateless, table, cache) = apply(transform, table)

"""
    Colwise

A transform that is applied column-by-column. In this case, the new type
only needs to implement [`colapply`](@ref), [`colrevert`](@ref) and
[`colcache`](@ref). Efficient fallbacks are provided that execute these
functions in parallel for all columns with multiple threads.
"""
abstract type Colwise <: Transform end

"""
    y = colapply(transform, x, c)

Apply `transform` to column `x` with cache `c` and return new column `y`.
"""
function colapply end

"""
    x = colrevert(transform, y, c)

Revert `transform` starting from column `y` with cache `c` and return
original column `x`. Only defined when the `transform` [`isrevertible`](@ref).
"""
function colrevert end

"""
    c = colcache(transform, x)

Produce cache `c` necessary to [`colapply`](@ref) the `transform` on `x`.
If the `transform` [`isrevertible`](@ref) then the cache `c` can also be
used in [`colrevert`](@ref).
"""
function colcache end

# ----------------
# IMPLEMENTATIONS
# ----------------

include("transforms/identity.jl")
include("transforms/select.jl")
include("transforms/center.jl")
include("transforms/scale.jl")
include("transforms/zscore.jl")
include("transforms/quantile.jl")
include("transforms/functional.jl")
include("transforms/eigenanalysis.jl")
include("transforms/sequential.jl")
include("transforms/parallel.jl")
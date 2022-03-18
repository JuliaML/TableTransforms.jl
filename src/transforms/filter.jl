# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Filter(f(), table)

The transform that filters the rows based on a given function.
"""
struct Filter <: Stateless
    f::Base.Callable
end

isrevertible(::Type{Filter}) = false

function apply(transform::Filter, table)
    [i for i in table if transform.f(i)], nothing
end
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

isrevertible(::Type{Filter}) = true

function apply(transform::Filter, table)
    indices = [i for i in range(1,length(table)) if transform.f(table[i])]
    table[indices], (indices, table[Not(indices)])
end

function revert(::Type{Filter}, newtable, cache)
    indices = cache[1]
    org_table = cache[2]

    for i in range(1, length(indices))
        insert!(org_table, indices[i], newtable[i])
    end

    org_table
end
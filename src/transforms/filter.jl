# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Filter(f(), table)

The transform that filters the rows based on a given function.
"""
struct Filter <: Transform
    f::Base.Callable
end

isrevertible(::Type{Filter}) = true


#Ideally, this function would also work without a given function, as follows:
#[item for item in iterable if item]
function apply(transform::Filter, table)
    indices = [i for i in range(1,length(table)) if transform.f(table[i])]
    table[indices], (indices, table[_minus(indices, table)])
end


function revert(::Type{Filter}, newtable, cache)
    indices = copy(cache[1])
    org_table = copy(cache[2])

    for i in range(1, length(indices))
        insert!(org_table, indices[i], newtable[i])
    end

    org_table
end

# Exclude the given indices
_minus(indx, x) = setdiff(1:length(x), indx)
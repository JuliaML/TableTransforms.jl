# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DropMissing()

The transform that drops the rows with missing values.
"""
struct DropMissing <: Stateless end

isrevertible(::Type{DropMissing}) = false

apply(::DropMissing, table) = dropmissing(table), nothing


# The following lines of code were taken from https://github.com/JuliaData/TableOperations.jl/blob/main/src/TableOperations.jl
# filter
struct Filter{F, T}
    f::F
    x::T
end

"""
    TableOperations.filter(f, source) => TableOperations.Filter
    source |> TableOperations.filter(f) => TableOperations.Filter
Create a lazy wrapper that satisfies the Tables.jl interface and keeps the rows where `f(row)` is true.
"""
function filter end

function filter(f::F, x) where {F <: Base.Callable}
    r = Tables.rows(x)
    return Filter{F, typeof(r)}(f, r)
end
filter(f::Base.Callable) = x->filter(f, x)

Tables.isrowtable(::Type{<:Filter}) = true
Tables.schema(f::Filter) = Tables.schema(f.x)

Base.IteratorSize(::Type{Filter{F, T}}) where {F, T} = Base.SizeUnknown()
Base.IteratorEltype(::Type{Filter{F, T}}) where {F, T} = Base.IteratorEltype(T)
Base.eltype(f::Filter) = eltype(f.x)

 @inline function Base.iterate(f::Filter)
    state = iterate(f.x)
    state === nothing && return nothing
    while !f.f(state[1])
        state = iterate(f.x, state[2])
        state === nothing && return nothing
    end
    return state
end

 @inline function Base.iterate(f::Filter, st)
    state = iterate(f.x, st)
    state === nothing && return nothing
    while !f.f(state[1])
        state = iterate(f.x, state[2])
        state === nothing && return nothing
    end
    return state
end

# dropmissing
"""
    TableOperations.dropmissing(source) => TableOperations.Filter
    source |> TableOperations.dropmissing() => TableOperations.Filter
Take a Tables.jl-compatible source and filter lazily every row where missing values are present.
"""
function dropmissing(table)
    return filter(_check_no_missing_in_row, table)
end

dropmissing() = x -> dropmissing(x)

function _check_no_missing_in_row(row)
    for el in row
        el === missing && return false
    end

    return true
end

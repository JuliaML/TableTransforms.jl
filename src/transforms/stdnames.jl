# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    StdNames(S)

StdNames transform standardizes the column names.
"""
struct StdNames <: Stateless
    stdmethod::Symbol
end

isrevertible(::Type{StdNames}) = true

function apply(transform::StdNames, table)    
    if transform.stdmethod == :camel
        _camel(table)
    elseif transform.stdmethod == :snake
        _snake(table)
    else
        _upper(table)
    end
end

function revert(::StdNames, newtable, cache)
    names = Tables.columnnames(newtable)
    namesdict = Dict(zip(names, cache))
    newtable |> Rename(namesdict)
end

function _camel(table)
    oldnames = Tables.columnnames(table)
    function camelfunction(x)
        substrings = split(string(x))
        capitalize(s) = String([i == 1 ? uppercase(c) : c for (i, c) in enumerate(s)])
        Symbol(join(map(capitalize, substrings)))
    end

    newnames = map(camelfunction, oldnames)
    namesdict = Dict(zip(oldnames, newnames))
    table |> Rename(namesdict), oldnames
end

function _snake(table)
    oldnames = Tables.columnnames(table)
    snakefunction(x) = Symbol(join(split(string(x)), "_"))
    newnames = map(snakefunction, oldnames)
    namesdict = Dict(zip(oldnames, newnames))
    table |> Rename(namesdict), oldnames
end

function _upper(table)
    oldnames = Tables.columnnames(table)
    upperfunction(x) = Symbol(uppercase(string(x)))    
    newnames = map(upperfunction, oldnames)
    namesdict = Dict(zip(oldnames, newnames))
    table |> Rename(namesdict), oldnames
end

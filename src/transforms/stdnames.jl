# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    StdNames(S)

StdNames transform standardizes the column names.
"""
struct StdNames <: Stateless
  spec::Symbol
end

StdNames() = StdNames(:upper)

isrevertible(::Type{StdNames}) = true

function apply(transform::StdNames, table)  
  oldnames = Tables.columnnames(table)
  spec = transform.spec

  (spec == :camel) && (newnames = map(_camel, oldnames))
  (spec == :snake) && (newnames = map(_snake, oldnames))
  (spec == :upper) && (newnames = map(_upper, oldnames))

  names = Dict(zip(oldnames, newnames))
  table |> Rename(names), oldnames
end

function revert(::StdNames, newtable, cache)
  newnames = Tables.columnnames(newtable)
  names = Dict(zip(newnames, cache))
  newtable |> Rename(names)
end

function _camel(name)
  substrings = split(string(name))
  capitalize(s) = String([i == 1 ? uppercase(c) : c for (i, c) in enumerate(s)])
  Symbol(join(map(capitalize, substrings)))
end

function _snake(name)
  Symbol(join(split(string(name)), "_"))
end

function _upper(name)
  Symbol(uppercase(string(name)))
end

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
  cols = Tables.columns(table)
  oldnames = Tables.columnnames(cols)
  spec = transform.spec

  (spec == :camel) && (newnames = map(_camel, map(string, oldnames)))
  (spec == :snake) && (newnames = map(_snake, map(string, oldnames)))
  (spec == :upper) && (newnames = map(_upper, map(string, oldnames)))

  newnames = map(Symbol, newnames)
  names = Dict(zip(oldnames, newnames))
  rtrans = Rename(names)
  newtable, rcache = apply(rtrans, table)
  newtable, (rtrans, rcache)
end

function revert(::StdNames, newtable, cache)
  rtrans, rcache = cache
  revert(rtrans, newtable, rcache)
end

function _camel(name)
  substrings = split(name)
  join(map(uppercasefirst, substrings))
end

function _snake(name)
  lowercase(join(split(name), "_"))
end

function _upper(name)
  replace(uppercase(name), " " => "")
end

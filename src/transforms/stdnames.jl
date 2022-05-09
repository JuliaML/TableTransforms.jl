# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    StdNames(:spec)

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

  spec == :camel && (newstringnames = _camel.(string.(oldnames)))
  spec == :snake && (newstringnames = _snake.(string.(oldnames)))
  spec == :upper && (newstringnames = _upper.(string.(oldnames)))

  newuniquenames = _unique(newstringnames)
  newnames = Symbol.(newuniquenames)
  names = Dict(zip(oldnames, newnames))

  rtrans = Rename(names)
  newtable, rcache = apply(rtrans, table)

  newtable, (rtrans, rcache)
end

function revert(::StdNames, newtable, cache)
  rtrans, rcache = cache
  revert(rtrans, newtable, rcache)
end

const delim = ['_', ' ']

function _unique(names)
  uniquenames = [names...]
  for i in range(2,length(uniquenames))
      prev = uniquenames[1:i-1]
      while uniquenames[i] in prev
        uniquenames[i] = string(uniquenames[i], "_")
      end
  end

  Tuple(uniquenames)
end

_camel(name) = join(uppercasefirst.(split(strip(name, delim), delim)))

_snake(name) = lowercase(join(split(strip(name, delim), delim), '_'))

_upper(name) = replace(uppercase(strip(name, delim)), delim => "")

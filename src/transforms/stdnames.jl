# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    StdNames(spec)

Standardizes column names according to given `spec`.
Default to `:upper` case specification.

# Specs

* `:upper` - Uppercase, e.g. COLUMNNAME
* `:camel` - Camelcase, e.g. ColumnName
* `:snake` - Snakecase, e.g. column_name
"""
struct StdNames <: Stateless
  spec::Symbol
end

StdNames() = StdNames(:upper)

isrevertible(::Type{StdNames}) = true

function apply(transform::StdNames, table)  
  # retrieve spec
  spec = transform.spec
  
  # retrieve column names
  cols = Tables.columns(table)
  oldnames = string.(Tables.columnnames(cols))
  
  # clean column names
  cleaned = _clean.(oldnames)

  # apply spec
  spec == :camel && (names = _camel.(cleaned))
  spec == :snake && (names = _snake.(cleaned))
  spec == :upper && (names = _upper.(cleaned))

  newnames = _unique(names)
  oldnew = Dict(zip(oldnames, newnames))

  rtrans = Rename(oldnew)
  newtable, rcache = apply(rtrans, table)

  newtable, (rtrans, rcache)
end

function revert(::StdNames, newtable, cache)
  rtrans, rcache = cache
  revert(rtrans, newtable, rcache)
end

const delim = [' ', '\t', '-', '_']

_clean(name) = filter(c -> isdigit(c) || isletter(c) || c ∈ delim, name)
  
function _unique(names)
  newnames = String[]
  for name in names
    n = name
    while n ∈ newnames
      n = string(n, "_")
    end
    push!(newnames, n)
  end

  newnames
end

_camel(name) = join(uppercasefirst.(split(name, delim)))

_snake(name) = join(lowercase.(split(strip(name, delim), delim)), '_')

_upper(name) = replace(uppercase(name), delim => "")

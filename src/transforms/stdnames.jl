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
  oldnames = string.(Tables.columnnames(cols))
  
  spec = transform.spec

  spec == :camel && (names = _camel.(oldnames))
  spec == :snake && (names = _snake.(oldnames))
  spec == :upper && (names = _upper.(oldnames))

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

const delim = ['_', ' ']

function _unique(names)
  newnames = String[]
  for name in names
    updatedname = name
    while updatedname ∈ newnames
      updatedname = string(updatedname, "_")
    end
    push!(newnames, updatedname)
  end

  newnames
end

_camel(name) = join(uppercasefirst.(split(strip(name, delim), delim)))

_snake(name) = lowercase(join(split(strip(name, delim), delim), '_'))

_upper(name) = replace(uppercase(strip(name, delim)), delim => "")

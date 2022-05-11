# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    StdNames(:spec)

The transform that standardizes the column names.
There are three different methods of standardization: `:upper`, `:camel`, and `:snake`.
Transform defaults to `:upper`.

# Examples

| Transform | Original Col. Name | Transformed Col. Name |
| ----------- | ----------- |	----------- |
| `StdNames`    		 | apple_Trees | APPLETREES |
| `StdNames(:upper)` | apple_Trees | APPLETREES |
| `StdNames(:camel)` | apple_Trees | AppleTrees |
| `StdNames(:snake)` | apple_Trees | apple_trees |

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
    n = name
    while n ∈ newnames
      n = string(n, "_")
    end
    push!(newnames, n)
  end

  newnames
end

_camel(name) = join(uppercasefirst.(split(strip(name, delim), delim)))

_snake(name) = join(lowercase.(split(strip(name, delim), delim)), '_')

_upper(name) = replace(uppercase(name), delim => "")

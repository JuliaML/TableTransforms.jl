# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

const SPECS = [:uppersnake, :uppercamel, :upperflat, :snake, :camel, :flat]

"""
    StdNames(spec = :uppersnake)

Standardizes column names according to given `spec`.
Default to `:uppersnake` case specification.

# Specs

* `:uppersnake` - Upper Snake Case, e.g. COLUMN_NAME
* `:uppercamel` - Upper Camel Case, e.g. ColumnName
* `:upperflat` - Upper Flat Case, e.g. COLUMNNAME
* `:snake` - Snake Case, e.g. column_name
* `:camel` - Camel Case, e.g. columnName
* `:flat` - Flat Case, e.g. columnname
"""
struct StdNames <: StatelessFeatureTransform
  spec::Symbol

  function StdNames(spec=:uppersnake)
    if spec ∉ SPECS
      throw(ArgumentError("invalid specification, use one of these: $SPECS"))
    end
    new(spec)
  end
end

isrevertible(::Type{StdNames}) = true

function applyfeat(transform::StdNames, feat, prep)
  # retrieve spec
  spec = transform.spec

  # retrieve column names
  cols = Tables.columns(feat)
  oldnames = Tables.columnnames(cols)

  # clean column names
  names = map(nm -> _clean(string(nm)), oldnames)

  # apply spec
  spec === :uppersnake && (names = _uppersnake.(names))
  spec === :uppercamel && (names = _uppercamel.(names))
  spec === :upperflat && (names = _upperflat.(names))
  spec === :snake && (names = _snake.(names))
  spec === :camel && (names = _camel.(names))
  spec === :flat && (names = _flat.(names))

  # make names unique
  newnames = _makeunique(names)

  # rename transform
  rtrans = Rename(colspec(oldnames), Symbol.(newnames))
  newfeat, rfcache = applyfeat(rtrans, feat, prep)

  newfeat, (rtrans, rfcache)
end

function revertfeat(::StdNames, newfeat, fcache)
  rtrans, rfcache = fcache
  revertfeat(rtrans, newfeat, rfcache)
end

const DELIMS = [' ', '\t', '-', '_']

function _clean(name)
  nm = strip(name, DELIMS)
  filter(c -> isdigit(c) || isletter(c) || c ∈ DELIMS, nm)
end

function _makeunique(names)
  newnames = String[]
  for name in names
    while name ∈ newnames
      name = name * "_"
    end
    push!(newnames, name)
  end
  newnames
end

_uppersnake(name) = _isuppersnake(name) ? name : join(uppercase.(split(name, DELIMS)), '_')

_uppercamel(name) = _isuppercamel(name) ? name : join(uppercasefirst.(split(name, DELIMS)))

_upperflat(name) = _isupperflat(name) ? name : replace(uppercase(name), DELIMS => "")

_snake(name) = _issnake(name) ? name : join(lowercase.(split(name, DELIMS)), '_')

function _camel(name)
  _iscamel(name) && return name
  first, others... = split(name, DELIMS)
  join([lowercase(first); uppercasefirst.(others)])
end

_flat(name) = _isflat(name) ? name : replace(lowercase(name), DELIMS => "")

_isuppersnake(name) = occursin(r"^[A-Z0-9]+(_[A-Z0-9]+)+$", name)
_isuppercamel(name) = occursin(r"^[A-Z][a-z0-9]*([A-Z][a-z0-9]*)+$", name)
_isupperflat(name) = occursin(r"^[A-Z0-9]+$", name)
_issnake(name) = occursin(r"^[a-z0-9]+(_[a-z0-9]+)+$", name)
_iscamel(name) = occursin(r"^[a-z][a-z0-9]*([A-Z][a-z0-9]*)+$", name)
_isflat(name) = occursin(r"^[a-z0-9]+$", name)

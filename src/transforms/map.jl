# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Map(cols₁ => fun₁ => target₁, ..., colsₙ => funₙ => targetₙ)

Applies the `funₙ` function to the columns selected by `colsₙ` using 
the `map` function and saves the result in a new column named `targetₙ`.
If the target column already exists in the table, the original
column will be replaced. The column selection can be a single
column identifier (index or name), a collection of identifiers
or a regular expression (regex).

# Examples

```julia
Map(1 => sin)
Map(:a => sin, "b" => cos => :b_cos)
Map([2, 3] => ((b, c) -> 2b + c))
Map([:a, :c] => ((a, c) -> 2a * 3c) => :col1)
Map(["c", "a"] => ((c, a) -> 3c / a) => :col1, "c" => tan)
Map(r"[abc]" => ((a, b, c) -> a^2 - 2b + c) => "col1")
```
"""
struct Map <: StatelessFeatureTransform
  colspecs::Vector{ColSpec}
  funs::Vector{Function}
  targets::Vector{Union{Nothing,Symbol}}
end

isrevertible(::Type{Map}) = true

# utility types
const TargetName = Union{Symbol,AbstractString}
const PairWithTarget = Pair{<:Any,<:Pair{<:Function,<:TargetName}}
const PairWithoutTarget = Pair{<:Any,<:Function}
const MapPair = Union{PairWithTarget,PairWithoutTarget}

# utility functions
_extract(p::PairWithTarget) = first(p), first(last(p)), last(last(p))
_extract(p::PairWithoutTarget) = first(p), last(p), nothing

_colspec(spec) = colspec(spec)
_colspec(col::Col) = colspec([col])

_target(name) = name
_target(name::AbstractString) = Symbol(name)

function Map(pairs::MapPair...)
  tuples = map(pairs) do p
    spec, fun, name = _extract(p)
    (_colspec(spec), fun, _target(name))
  end
  colspecs = map(t -> t[1], tuples) |> collect
  funs = map(t -> t[2], tuples) |> collect
  targets = map(t -> t[3], tuples) |> collect
  Map(colspecs, funs, targets)
end

_makename(snames, fun) = Symbol(join([snames; nameof(fun)], "_"))

function preprocess(transform::Map, table)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)

  colspecs = transform.colspecs
  funs = transform.funs
  targets = transform.targets

  map(colspecs, funs, targets) do colspec, fun, target
    snames = choose(colspec, names)
    newname = isnothing(target) ? _makename(snames, fun) : target
    columns = (Tables.getcolumn(cols, nm) for nm in snames)
    newcolumn = map(fun, columns...)
    newname => newcolumn
  end
end

function applyfeat(::Map, feat, prep)
  cols = Tables.columns(feat)
  onames = Tables.columnnames(cols)

  # new names and columns
  names = collect(onames)
  columns = Any[Tables.getcolumn(cols, nm) for nm in onames]

  # replaced names and columns
  rnames = empty(names)
  rcolumns = empty(columns)

  for (name, column) in prep
    if name ∈ onames
      push!(rnames, name)
      i = findfirst(==(name), onames)
      push!(rcolumns, columns[i])
      columns[i] = column
    else
      push!(names, name)
      push!(columns, column)
    end
  end

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)
  newfeat, (onames, rnames, rcolumns)
end

function revertfeat(::Map, newfeat, fcache)
  cols = Tables.columns(newfeat)

  onames, rnames, rcolumns = fcache
  ocolumns = map(onames) do name
    if name ∈ rnames
      i = findfirst(==(name), rnames)
      rcolumns[i]
    else
      Tables.getcolumn(cols, name)
    end
  end

  𝒯 = (; zip(onames, ocolumns)...)
  𝒯 |> Tables.materializer(newfeat)
end

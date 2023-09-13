# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Map(cols₁ => fun₁ => target₁, cols₂ => fun₂, ..., colsₙ => funₙ => targetₙ)

Applies the `funᵢ` function to the columns selected by `colsᵢ` using 
the `map` function and saves the result in a new column named `targetᵢ`.

The column selection can be a single column identifier (index or name),
a collection of identifiers or a regular expression (regex).

Passing a target column name is optional and when omitted a new name
is generated by joining the selected column names with the function name.
If the target column already exists in the table, the original
column will be replaced.

# Examples

```julia
Map(1 => sin)
Map(:a => sin, "b" => cos => :b_cos)
Map([2, 3] => ((b, c) -> 2b + c))
Map([:a, :c] => ((a, c) -> 2a * 3c) => :col1)
Map(["c", "a"] => ((c, a) -> 3c / a) => :col1, "c" => tan)
Map(r"[abc]" => ((a, b, c) -> a^2 - 2b + c) => "col1")
```

## Notes

* Anonymous functions must be passed with parentheses as in the examples above.
"""
struct Map <: StatelessFeatureTransform
  colspecs::Vector{ColSpec}
  funs::Vector{Function}
  targets::Vector{Union{Nothing,Symbol}}
end

Map() = throw(ArgumentError("cannot create a Map transform without arguments"))

# utility types
const TargetName = Union{Symbol,AbstractString}
const PairWithTarget = Pair{<:Any,<:Pair{<:Function,<:TargetName}}
const PairWithoutTarget = Pair{<:Any,<:Function}
const MapPair = Union{PairWithTarget,PairWithoutTarget}

# utility functions
_extract(p::PairWithTarget) = colspec(first(p)), first(last(p)), Symbol(last(last(p)))
_extract(p::PairWithoutTarget) = colspec(first(p)), last(p), nothing

function Map(pairs::MapPair...)
  tuples = map(_extract, pairs)
  colspecs = [t[1] for t in tuples]
  funs = [t[2] for t in tuples]
  targets = [t[3] for t in tuples]
  Map(colspecs, funs, targets)
end

isrevertible(::Type{Map}) = true

_makename(snames, fun) = Symbol(join([snames; nameof(fun)], "_"))

function applyfeat(transform::Map, feat, prep)
  cols = Tables.columns(feat)
  onames = Tables.columnnames(cols)

  colspecs = transform.colspecs
  funs = transform.funs
  targets = transform.targets

  # new names and columns
  names = collect(onames)
  columns = Any[Tables.getcolumn(cols, nm) for nm in onames]

  # replaced names and columns
  rnames = empty(names)
  rcolumns = empty(columns)

  # mapped columns
  mapped = map(colspecs, funs, targets) do colspec, fun, target
    snames = choose(colspec, names)
    newname = isnothing(target) ? _makename(snames, fun) : target
    columns = (Tables.getcolumn(cols, nm) for nm in snames)
    newcolumn = map(fun, columns...)
    newname => newcolumn
  end

  for (name, column) in mapped
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

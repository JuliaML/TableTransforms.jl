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
is generated by joining the function name with the selected column names.
If the target column already exists in the table, the original
column will be replaced.

# Examples

```julia
Map(1 => sin)
Map(:a => sin, "b" => cos => :cos_b)
Map([2, 3] => ((b, c) -> 2b + c))
Map([:a, :c] => ((a, c) -> 2a * 3c) => :col1)
Map(["c", "a"] => ((c, a) -> 3c / a) => :col1, "c" => tan)
Map(r"[abc]" => ((a, b, c) -> a^2 - 2b + c) => "col1")
```

## Notes

* Anonymous functions must be passed with parentheses as in the examples above;
* Some function names are treated in a special way, they are:
  * Anonymous functions: `#1` -> `f1`;
  * Composed functions: `outer ∘ inner` -> `outer_inner`;
  * `Base.Fix1` functions: `Base.Fix1(f, x)` -> `fix1_f`;
  * `Base.Fix2` functions: `Base.Fix2(f, x)` -> `fix2_f`;
"""
struct Map <: StatelessFeatureTransform
  selectors::Vector{ColumnSelector}
  funs::Vector{Function}
  targets::Vector{Union{Nothing,Symbol}}
end

Map() = throw(ArgumentError("cannot create Map transform without arguments"))

# utility types
const TargetName = Union{Symbol,AbstractString}
const PairWithTarget = Pair{<:Any,<:Pair{<:Function,<:TargetName}}
const PairWithoutTarget = Pair{<:Any,<:Function}
const MapPair = Union{PairWithTarget,PairWithoutTarget}

# utility functions
_extract(p::PairWithTarget) = selector(first(p)), first(last(p)), Symbol(last(last(p)))
_extract(p::PairWithoutTarget) = selector(first(p)), last(p), nothing

function Map(pairs::MapPair...)
  tuples = map(_extract, pairs)
  selectors = [t[1] for t in tuples]
  funs = [t[2] for t in tuples]
  targets = [t[3] for t in tuples]
  Map(selectors, funs, targets)
end

isrevertible(::Type{Map}) = false

_funname(fun::Base.Fix1) = "fix1_" * _funname(fun.f)
_funname(fun::Base.Fix2) = "fix2_" * _funname(fun.f)
_funname(fun::ComposedFunction) = _funname(fun.outer) * "_" * _funname(fun.inner)
_funname(fun) = string(fun)

function _makename(snames, fun)
  funname = _funname(fun)
  if contains(funname, "#") # anonymous functions
    funname = replace(funname, "#" => "f")
  end
  Symbol(funname, :_, join(snames, "_"))
end

function applyfeat(transform::Map, feat, prep)
  cols = Tables.columns(feat)
  onames = Tables.columnnames(cols)

  selectors = transform.selectors
  funs = transform.funs
  targets = transform.targets

  # new names and columns
  names = collect(onames)
  columns = Any[Tables.getcolumn(cols, nm) for nm in onames]

  # mapped columns
  mapped = map(selectors, funs, targets) do selector, fun, target
    snames = selector(names)
    newname = isnothing(target) ? _makename(snames, fun) : target
    scolumns = (Tables.getcolumn(cols, nm) for nm in snames)
    newcolumn = map(fun, scolumns...)
    newname => newcolumn
  end

  for (name, column) in mapped
    if name ∈ onames
      i = findfirst(==(name), onames)
      columns[i] = column
    else
      push!(names, name)
      push!(columns, column)
    end
  end

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)
  newfeat, nothing
end

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Replace(cols₁ => pred₁ => new₁, pred₂ => new₂, ..., colsₙ => predₙ => newₙ)

Replaces all values where `predᵢ` predicate returns `true` with `newᵢ` value 
in the the columns selected by `colsᵢ`.

Passing a column selection is optional and when omitted all columns in the table 
will be selected. The column selection can be a single column identifier (index or name), 
a collection of identifiers, or a regular expression (regex).

The predicate can be a function that accepts a single argument
and returns a boolean, or a value. If the predicate is a value,
it will be transformed into the following function: `x -> x === value`.

## Examples

```julia
Replace(1 => -1, 5 => -5)
Replace(2 => 0.0 => 1.5, 5.0 => 5.5)
Replace(:b => 0.0 => 1.5, 5.0 => 5.5)
Replace("b" => 0.0 => 1.5, 5.0 => 5.5)
Replace([1, 3] => >(5) => 5)
Replace([:a, :c] => isequal(2) => -2)
Replace(["a", "c"] => (x -> 4 < x < 6) => 0)
Replace(r"[abc]" => (x -> isodd(x) && x > 10) => 2)
```

## Notes

* Anonymous functions must be passed with parentheses as in the examples above.
* Replacements are applied in the sequence in which they are defined, therefore,
  if there is more than one replacement for the same column, the first valid one will be applied.
"""
struct Replace <: StatelessFeatureTransform
  selectors::Vector{ColumnSelector}
  preds::Vector{Function}
  news::Vector{Any}
end

Replace() = throw(ArgumentError("cannot create Replace transform without arguments"))

# utility functions
_extract(p::Pair) = AllSelector(), _pred(first(p)), last(p)
_extract(p::Pair{<:Any,<:Pair}) = selector(first(p)), _pred(first(last(p))), last(last(p))

_pred(f::Function) = f
_pred(v) = Base.Fix2(===, v)

function Replace(pairs::Pair...)
  tuples = map(_extract, pairs)
  selectors = [t[1] for t in tuples]
  preds = [t[2] for t in tuples]
  news = Any[t[3] for t in tuples]
  Replace(selectors, preds, news)
end

function applyfeat(transform::Replace, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)

  selectors = transform.selectors
  preds = transform.preds
  news = transform.news

  # preprocess all replacements
  prepreps = map(selectors, preds, news) do selector, pred, new
    snames = selector(names)
    snames => pred => new
  end

  # join replacements of each column
  colreps = map(names) do name
    pairs = filter(p -> name ∈ first(p), prepreps)
    reps = isempty(pairs) ? nothing : map(last, pairs)
    name => reps
  end

  columns = map(colreps) do (name, reps)
    x = Tables.getcolumn(cols, name)
    if isnothing(reps)
      x
    else
      map(x) do v
        for (pred, new) in reps
          if pred(v)
            return new
          end
        end
        v
      end
    end
  end

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)
  newfeat, nothing
end

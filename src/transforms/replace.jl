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

# Examples

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
  colspecs::Vector{ColSpec}
  preds::Vector{Function}
  news::Vector{Any}
end

Replace() = throw(ArgumentError("cannot create a Replace transform without arguments"))

# utility functions
_extract(p::Pair) = AllSpec(), _pred(first(p)), last(p)
_extract(p::Pair{<:Any,<:Pair}) = colspec(first(p)), _pred(first(last(p))), last(last(p))

_pred(f::Function) = f
_pred(v) = Base.Fix2(===, v)

function Replace(pairs::Pair...)
  tuples = map(_extract, pairs)
  colspecs = [t[1] for t in tuples]
  preds = [t[2] for t in tuples]
  news = Any[t[3] for t in tuples]
  Replace(colspecs, preds, news)
end

isrevertible(::Type{<:Replace}) = true

function applyfeat(transform::Replace, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)

  colspecs = transform.colspecs
  preds = transform.preds
  news = transform.news

  # preprocess all replacements
  prepreps = map(colspecs, preds, news) do colspec, pred, new
    snames = choose(colspec, names)
    snames => pred => new
  end

  # join replacements of each column
  colreps = map(names) do name
    pairs = filter(p -> name ∈ first(p), prepreps)
    reps = isempty(pairs) ? nothing : map(last, pairs)
    name => reps
  end

  tuples = map(colreps) do (name, reps)
    x = Tables.getcolumn(cols, name)
    if isnothing(reps)
      x, nothing
    else
      # reversal dict
      rev = Dict{Int,eltype(x)}()
      y = map(enumerate(x)) do (i, v)
        for (pred, new) in reps
          if pred(v)
            rev[i] = v
            return new
          end
        end
        v
      end
      y, rev
    end
  end

  columns = first.(tuples)
  fcache = last.(tuples)

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)
  newfeat, fcache
end

function revertfeat(::Replace, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)

  columns = map(names, fcache) do name, rev
    y = Tables.getcolumn(cols, name)
    isnothing(rev) ? y : [get(rev, i, y[i]) for i in 1:length(y)]
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

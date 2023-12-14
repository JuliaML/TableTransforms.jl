# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Filter(pred)

Filters the table returning only the rows where
the predicate `pred` is `true`.

# Examples

```julia
Filter(row -> sum(row) > 10)
Filter(row -> row.a == true && row.b < 30)
Filter(row -> row."a" == true && row."b" < 30)
Filter(row -> row[1] == true && row[2] < 30)
Filter(row -> row[:a] == true && row[:b] < 30)
Filter(row -> row["a"] == true && row["b"] < 30)
```

## Notes

* The schema of the table is preserved by the transform.
"""
struct Filter{F} <: StatelessFeatureTransform
  pred::F
end

isrevertible(::Type{<:Filter}) = false

function preprocess(transform::Filter, feat)
  # lazy row iterator
  rows = tablerows(feat)

  # selected indices
  sinds = Int[]
  for (i, row) in enumerate(rows)
    transform.pred(row) && push!(sinds, i)
  end

  sinds
end

function applyfeat(::Filter, feat, prep)
  # preprocessed indices
  sinds = prep

  # selected rows
  srows = Tables.subset(feat, sinds, viewhint=true)

  newfeat = srows |> Tables.materializer(feat)
  newfeat, nothing
end

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

isrevertible(::Type{<:Filter}) = true

function preprocess(transform::Filter, feat)
  # lazy row iterator
  rows = tablerows(feat)

  # selected indices
  sinds, nrows = Int[], 0
  for (i, row) in enumerate(rows)
    transform.pred(row) && push!(sinds, i)
    nrows += 1
  end

  # rejected indices
  rinds = setdiff(1:nrows, sinds)

  sinds, rinds
end

function applyfeat(::Filter, feat, prep)
  # collect all rows
  rows = Tables.rowtable(feat)

  # preprocessed indices
  sinds, rinds = prep

  # select/reject rows
  srows = view(rows, sinds)
  rrows = view(rows, rinds)

  newfeat = srows |> Tables.materializer(feat)

  newfeat, (rinds, rrows)
end

function revertfeat(::Filter, newfeat, fcache)
  # collect all rows
  rows = Tables.rowtable(newfeat)

  rinds, rrows = fcache
  for (i, row) in zip(rinds, rrows)
    insert!(rows, i, row)
  end

  rows |> Tables.materializer(newfeat)
end

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
  # preprocessed indices
  sinds, rinds = prep

  # selected/rejected rows
  srows = Tables.subset(feat, sinds, viewhint=true)
  rrows = Tables.subset(feat, rinds, viewhint=true)

  newfeat = srows |> Tables.materializer(feat)

  newfeat, (rinds, rrows)
end

function revertfeat(::Filter, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)

  rinds, rrows = fcache

  # columns with selected rows
  columns = map(names) do name
    collect(Tables.getcolumn(cols, name))
  end

  # insert rejected rows into columns
  rrcols = Tables.columns(rrows)
  for (name, x) in zip(names, columns)
    r = Tables.getcolumn(rrcols, name)
    for (i, v) in zip(rinds, r)
      insert!(x, i, v)
    end
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

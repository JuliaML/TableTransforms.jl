# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Replace(pred₁ => new₁, pred₂ => new₂, ..., predₙ => newₙ)

Replaces all values where `predᵢ` predicate returns `true` with `newᵢ` value in the table.

The predicate can be a function that accepts a single argument and returns a boolean, or a value. 
If the predicate is a value, it will be transformed into the following function:
`x -> x === value`.

# Examples

```julia
Replace(1 => -1, 5 => -5)
Replace(1 => 1.5, 5 => 5.5, 4 => true)
Replace(>(3) => 10, isequal(2) => true)
Replace(1 => 1.6, <(3) => 11, (x -> 4 < x < 6) => true)
```

## Notes

* If it is not possible to apply the predicate to the value (e.g. `5 > "str"`),
  the comparison will return `false`.
"""
struct Replace{F,V} <: StatelessFeatureTransform
  funs::Vector{F}
  values::Vector{V}
end

Replace() = throw(ArgumentError("cannot create a Replace transform without arguments"))

function Replace(pairs::Pair...)
  funs = map(first.(pairs)) do f
    f isa Function ? f : Base.Fix2(===, f)
  end
  Replace(collect(funs), collect(last.(pairs)))
end

isrevertible(::Type{<:Replace}) = true

trycompare(f, v) = try f(v) catch; false end

function applyfeat(transform::Replace, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)

  funs = transform.funs
  news = transform.values
  tuples = map(names) do nm
    olds = []
    x = Tables.getcolumn(cols, nm)
    y = map(enumerate(x)) do (i, v)
      for (f, n) in zip(funs, news)
        if trycompare(f, v)
          push!(olds, i => v)
          return n
        end
      end
      v
    end
    y, Dict(olds)
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

  columns = map(names, fcache) do nm, rev
    y = Tables.getcolumn(cols, nm)
    [get(rev, i, y[i]) for i in eachindex(y)]
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

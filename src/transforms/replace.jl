# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Replace(old₁ => new₁, old₂ => new₂, ..., oldₙ => newₙ)

Replaces `oldᵢ` value with `newᵢ` value in the table.

# Examples

```julia
Replace(1 => -1, 5 => -5)
Replace(1 => 1.5, 5 => 5.5, 4 => true)
```
"""
struct Replace{K,V} <: StatelessFeatureTransform
  pairs::IdDict{K,V}
end

Replace() = throw(ArgumentError("Cannot create a Replace object without arguments."))

Replace(pairs::Pair...) = Replace(IdDict(values(pairs)))

isrevertible(::Type{<:Replace}) = true

function applyfeat(transform::Replace, feat, prep)
  cols  = Tables.columns(feat)
  names = Tables.columnnames(cols)

  olds = keys(transform.pairs)
  values = map(names) do nm
    x    = Tables.getcolumn(cols, nm)
    y    = [get(transform.pairs, xᵢ, xᵢ) for xᵢ in x]
    inds = [findall(xᵢ -> xᵢ === old, x) .=> old for old in olds]
    rev  = Dict(reduce(vcat, inds))
    y, rev
  end

  columns = first.(values)
  fcache  = last.(values)

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)
  newfeat, fcache
end

function revertfeat(::Replace, newfeat, fcache)
  cols  = Tables.columns(newfeat)
  names = Tables.columnnames(cols)

  columns = map(names, fcache) do nm, rev
    y = Tables.getcolumn(cols, nm)
    [get(rev, i, y[i]) for i in eachindex(y)]
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

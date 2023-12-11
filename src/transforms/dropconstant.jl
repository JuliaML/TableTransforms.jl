# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DropConstant()

Drops the constant columns using the `allequal` function.
"""
struct DropConstant <: StatelessFeatureTransform end

isrevertible(::Type{DropConstant}) = true

function applyfeat(::DropConstant, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols) |> collect

  # constant columns
  cnames = filter(names) do name
    x = Tables.getcolumn(cols, name)
    allequal(x)
  end
  cinds = indexin(cnames, names)
  cvalues = [first(Tables.getcolumn(cols, nm)) for nm in cnames]

  # selected columns
  snames = setdiff(names, cnames)
  columns = [Tables.getcolumn(cols, nm) for nm in snames]

  𝒯 = (; zip(snames, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)
  newfeat, (cinds, cnames, cvalues)
end

function revertfeat(::DropConstant, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols) |> collect
  columns = Any[Tables.getcolumn(cols, name) for name in names]

  cinds, cnames, cvalues = fcache

  nrows = _nrows(newfeat)
  for (i, cind) in enumerate(cinds)
    insert!(names, cind, cnames[i])
    insert!(columns, cind, fill(cvalues[i], nrows))
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

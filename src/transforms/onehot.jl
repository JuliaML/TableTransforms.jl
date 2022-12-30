# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    OneHot(col, categorical)

Transforms categorical column `col` into one-hot columns of levels
returned by the `levels` function of CategoricalArrays.jl.
The `categorical` parameter is a bool type parameter, if set to true, 
the one-hot columns will be categorical vectors, if set to false, 
the one-hot columns will be bit vectors.

# Examples

```julia
OneHot(1)
OneHot(:a)
OneHot("a")
```
"""
struct OneHot{S<:ColSpec} <: StatelessFeatureTransform
  colspec::S
  categorical::Bool
  function OneHot(col::Col, categorical::Bool=true)
    cs = colspec([col])
    new{typeof(cs)}(cs, categorical)
  end
end

isrevertible(::Type{<:OneHot}) = true

function applyfeat(transform::OneHot, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols) |> collect
  columns = Any[Tables.getcolumn(cols, nm) for nm in names]

  name = choose(transform.colspec, names)[1]
  ind = findfirst(==(name), names)
  x = columns[ind]

  assert_categorical(x)

  xl = levels(x)
  onehot = map(xl) do l
    nm = Symbol("$(name)_$l")
    while nm ∈ names
      nm = Symbol("$(nm)_")
    end
    nm, x .== l
  end

  newnms, newcols = first.(onehot), last.(onehot)
  if transform.categorical == true
    newcols = [categorical(newcol; levels=nothing, ordered=false, compress=false) for newcol in newcols]
  end
  splice!(names, ind, newnms)
  splice!(columns, ind, newcols)
  
  inds = ind:(ind + length(newnms) - 1)

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)
  newfeat, (name, inds, xl, isordered(x))
end

function revertfeat(::OneHot, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols) |> collect
  columns = Any[Tables.getcolumn(cols, nm) for nm in names]
  
  oname, inds, levels, ordered = fcache
  x = map(zip(columns[inds]...)) do row
    levels[findfirst(row)]
  end

  ocolumn = categorical(x; levels, ordered)

  splice!(names, inds, [oname])
  splice!(columns, inds, [ocolumn])

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

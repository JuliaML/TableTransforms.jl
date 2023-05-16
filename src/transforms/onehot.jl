# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    OneHot(col; categ=true)

Transforms categorical column `col` into one-hot columns of levels
returned by the `levels` function of CategoricalArrays.jl.
The `categ` option can be used to convert resulting
columns to categorical arrays as opposed to boolean vectors.

# Examples

```julia
OneHot(1)
OneHot(:a)
OneHot("a")
OneHot("a", categ=false)
```
"""
struct OneHot{S<:ColSpec} <: StatelessFeatureTransform
  colspec::S
  categ::Bool
  function OneHot(col, categ)
    cs = colspec([col])
    new{typeof(cs)}(cs, categ)
  end
end

OneHot(col; categ=true) = OneHot(col, categ)

assertions(transform::OneHot) = [SciTypeAssertion{Finite}(transform.colspec)]

isrevertible(::Type{<:OneHot}) = true

function applyfeat(transform::OneHot, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols) |> collect
  columns = Any[Tables.getcolumn(cols, nm) for nm in names]

  name = choose(transform.colspec, names)[1]
  ind = findfirst(==(name), names)
  x = columns[ind]

  xl = levels(x)
  onehot = map(xl) do l
    nm = Symbol("$(name)_$l")
    while nm ∈ names
      nm = Symbol("$(nm)_")
    end
    nm, x .== l
  end

  newnms, newcols = first.(onehot), last.(onehot)

  # convert to categorical arrays if necessary
  newcols = transform.categ ? categorical.(newcols, levels=[false, true]) : newcols

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
    levels[findfirst(==(true), row)]
  end

  ocolumn = categorical(x; levels, ordered)

  splice!(names, inds, [oname])
  splice!(columns, inds, [ocolumn])

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

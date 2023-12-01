# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    OneHot(col; categ=false)

Transforms categorical column `col` into one-hot columns of levels
returned by the `levels` function of CategoricalArrays.jl.
The `categ` option can be used to convert resulting
columns to categorical arrays as opposed to boolean vectors.

# Examples

```julia
OneHot(1)
OneHot(:a)
OneHot("a")
OneHot("a", categ=true)
```
"""
struct OneHot{S<:SingleColumnSelector} <: StatelessFeatureTransform
  selector::S
  categ::Bool
end

OneHot(col::Column; categ=false) = OneHot(selector(col), categ)

assertions(transform::OneHot) = [scitypeassert(Categorical, transform.selector)]

isrevertible(::Type{<:OneHot}) = true

_categ(x) = categorical(x), identity
function _categ(x::CategoricalArray)
  l, o = levels(x), isordered(x)
  revfun = y -> categorical(y, levels=l, ordered=o)
  x, revfun
end

function applyfeat(transform::OneHot, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols) |> collect
  columns = Any[Tables.getcolumn(cols, nm) for nm in names]

  name = selectsingle(transform.selector, names)
  ind = findfirst(==(name), names)
  x, revfun = _categ(columns[ind])

  xlevels = levels(x)
  onehot = map(xlevels) do l
    nm = Symbol("$(name)_$l")
    while nm ∈ names
      nm = Symbol("$(nm)_")
    end
    nm, x .== l
  end

  newnames = first.(onehot)
  newcolumns = last.(onehot)

  # convert to categorical arrays if necessary
  newcolumns = transform.categ ? categorical.(newcolumns, levels=[false, true]) : newcolumns

  splice!(names, ind, newnames)
  splice!(columns, ind, newcolumns)

  inds = ind:(ind + length(newnames) - 1)

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)
  newfeat, (name, inds, xlevels, revfun)
end

function revertfeat(::OneHot, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols) |> collect
  columns = Any[Tables.getcolumn(cols, nm) for nm in names]

  oname, inds, levels, revfun = fcache
  y = map(zip(columns[inds]...)) do row
    levels[findfirst(==(true), row)]
  end

  ocolumn = revfun(y)

  splice!(names, inds, [oname])
  splice!(columns, inds, [ocolumn])

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    OneHot(col)
    
Transforms categorical column `col` into one-hot columns of levels
returned by the `levels` function of CategoricalArrays.jl.

# Examples

```julia
OneHot(1)
OneHot(:a)
OneHot("a")
```
"""
struct OneHot{S<:ColSpec} <: Stateless
  colspec::S
  function OneHot(col::Col)
    cs = colspec([col])
    new{typeof(cs)}(cs)
  end
end

isrevertible(::Type{<:OneHot}) = true

function applyfeat(transform::OneHot, table, prep)
  cols = Tables.columns(table)
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

  splice!(names, ind, newnms)
  splice!(columns, ind, newcols)
  
  inds = ind:(ind + length(newnms) - 1)

  𝒯 = (; zip(names, columns)...)
  newtable = 𝒯 |> Tables.materializer(table)
  newtable, (name, inds, xl, isordered(x))
end

function revertfeat(::OneHot, newtable, fcache)
  cols = Tables.columns(newtable)
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
  𝒯 |> Tables.materializer(newtable)
end

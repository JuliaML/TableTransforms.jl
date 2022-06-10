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
struct OneHot{S<:ColSelector} <: Stateless
  col::S
end

isrevertible(::Type{<:OneHot}) = true

_colname(col::Integer, names) = names[col]
_colname(col::AbstractString, names) =
  _colname(Symbol(col), names)

function _colname(col::Symbol, names)
  @assert col ∈ names "Invalid column selection."
  return col
end

_name(nm, names) = 
  nm ∈ names ? _name(Symbol("$(nm)_"), names) : nm

function apply(transform::OneHot, table)
  cols = Tables.columns(table)
  names = collect(Tables.columnnames(cols))
  columns = Any[Tables.getcolumn(cols, nm) for nm in names]
  
  name = _colname(transform.col, names)
  ind = findfirst(==(name), names)
  x = columns[ind]

  assert_categorical(x)

  xl = levels(x)
  onehot = map(xl) do l
    nm = Symbol("$(name)_$l")
    nm = _name(nm, names)
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

function revert(::OneHot, newtable, cache)
  cols = Tables.columns(newtable)
  names = collect(Tables.columnnames(cols))
  columns = Any[Tables.getcolumn(cols, nm) for nm in names]
  
  oname, inds, levels, ordered = cache
  x = map(zip(columns[inds]...)) do row
    levels[findfirst(row)]
  end

  ocolumn = categorical(x; levels, ordered)

  splice!(names, inds, [oname])
  splice!(columns, inds, [ocolumn])

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newtable)
end

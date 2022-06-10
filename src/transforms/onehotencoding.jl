# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    OneHotEncoding(col)
    
Transforms categorical column `col` into one-hot columns of levels
returned by the `levels` function of CategoricalArrays.jl.

# Examples

```julia
OneHotEncoding(1)
OneHotEncoding(:a)
OneHotEncoding("a")
```
"""
struct OneHotEncoding{S<:ColSelector} <: Stateless
  col::S
end

isrevertible(::Type{<:OneHotEncoding}) = true

_colname(col::Integer, names) = names[col]
_colname(col::AbstractString, names) =
  _colname(Symbol(col), names)

function _colname(col::Symbol, names)
  @assert col ∈ names "Invalid column."
  return col
end

_name(nm, names) = 
  nm ∈ names ? _name(Symbol("$(nm)_"), names) : nm

function apply(transform::OneHotEncoding, table)
  cols = Tables.columns(table)
  names = collect(Tables.columnnames(cols))
  columns = AbstractVector[Tables.getcolumn(cols, nm) for nm in names]
  
  name = _colname(transform.col, names)
  ind = findfirst(==(name), names)
  x = columns[ind]

  if !isa(x, CategoricalArray)
    throw(ArgumentError("The $name column must be cetegorical."))
  end

  xl = levels(x)
  onehot = map(xl) do l
    nm = Symbol("$(name)_$l")
    nm = _name(nm, names)
    nm, x .== l
  end

  newcols, newnms = last.(onehot), first.(onehot)

  splice!(columns, ind, newcols)
  splice!(names, ind, newnms)

  inds = ind:(ind + length(newnms) - 1)

  𝒯 = (; zip(names, columns)...)
  newtable = 𝒯 |> Tables.materializer(table)
  newtable, (name, inds, xl, isordered(x))
end

function revert(::OneHotEncoding, newtable, cache)
  cols = Tables.columns(newtable)
  names = collect(Tables.columnnames(cols))
  columns = AbstractVector[Tables.getcolumn(cols, nm) for nm in names]
  
  oname, inds, levels, ordered = cache
  x = map(zip(columns[inds]...)) do row
    levels[findfirst(row)]
  end

  ocolumn = categorical(x; levels, ordered)

  splice!(columns, inds, [ocolumn])
  splice!(names, inds, [oname])

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newtable)
end

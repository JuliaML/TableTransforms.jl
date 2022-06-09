# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    OneHotEncoding(col)
    
docstring.

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

_levels(x) = levels(categorical(x))
_levels(x::CategoricalArray) = levels(x)

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
  cols    = Tables.columns(table)
  names   = collect(Tables.columnnames(cols))
  colname = _colname(transform.col, names)
  colind  = findfirst(==(colname), names)
  columns = [Tables.getcolumn(cols, nm) for nm in names]

  x = Tables.getcolumn(cols, colname)
  levels = _levels(x)
  onehot = map(levels) do l
    name = _name(Symbol("$(colname)_$l"), names)
    name, x .== l
  end

  newcols, newnames = last.(onehot), first.(onehot)

  splice!(columns, colind, newcols)
  splice!(names, colind, newnames)

  𝒯 = (; zip(names, columns)...)
  newtable = 𝒯 |> Tables.materializer(table)
  newtable, newnames
end

function revert(::OneHotEncoding, newtable, cache)
  # code...
end

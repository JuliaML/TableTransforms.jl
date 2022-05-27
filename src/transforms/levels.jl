"""
    Levels(:a => ["yes", "no"])

Return a copy of the table with specified levels and orders for categorical columns
allowing only changing the order of the column.

# Examples

```julia
Levels(:a => ["yes, "no"], :c => [1, 2, 4], :d => ["a", "b", "c"])
Levels("a" => ["yes", "no"], "c" => [1, 2, 4], ordered = ["a", "c"])
Levels(:a => ["yes", "no"], :c => [1, 2, 4], :d => [1, 23, 5, 7], ordered = [:a, :b, :c])
```
"""
struct Levels{K} <: Stateless
  levelspec::K
  ordered::Vector{Symbol}
end

Levels(pairs::Pair{Symbol}...; ordered=Symbol[]) =
  Levels(NamedTuple(pairs), ordered)

Levels(pairs::Pair{K}...; ordered=K[]) where {K<:AbstractString} =
  Levels(NamedTuple(Symbol(k) => v for (k,v) in pairs), Symbol.(ordered))

isrevertible(transform::Levels) = true

# when the col is already a categorical array and wanna change levels and order
_categorify(l::AbstractVector, x::CategoricalVector, o) =
  categorical(x, levels=l, ordered=o), levels(x)

# when the col is normal array and want to change to categorical array
_categorify(l::AbstractVector, x::AbstractVector, o) =
  categorical(x, levels=l, ordered=o), unwrap 

# when the col is not need for change or convert back to normal array
_categorify(f::Function, x::AbstractVector, o) =
  o ? (categorical(x, ordered=true), levels(x)) : (f.(x), f)

function apply(transform::Levels, table)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)

  result = map(names) do nm
    x = Tables.getcolumn(cols, nm)
    l = get(transform.levelspec, nm, identity)
    o = nm ∈ transform.ordered
    _categorify(l, x, o)
  end
  
  categ = first.(result)
  cache = last.(result)

  𝒯 = (; zip(names, categ)...)
  newtable = 𝒯 |> Tables.materializer(table)
  
  newtable, cache
end

function revert(transform::Levels, newtable, cache)
  cols = Tables.columns(newtable)
  names = Tables.columnnames(cols)

  ocols = map(zip(cache, names)) do (f, nm)
    x = Tables.getcolumn(cols, nm)
    c, _ = _categorify(f, x, false)
    c
  end

  𝒯 = (; zip(names, ocols)...)
  𝒯 |> Tables.materializer(newtable)
end
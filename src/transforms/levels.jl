"""
    Levels(:a => ["yes,"no"])

Return a copy of the table with specified levels and orders for categorical columns
allowing only changing the order of the column.

# Examples

```julia
Levels(:a => ["yes,"no"], :c => [1,2,4], :d => ["a","b","c"])
Levels("a" => ["yes","no"], "c" => [1,2,4], ordered = ["a","c"])
Levels(:a => ["yes","no"], :c => [1,2,4], :d => [1,23,5,7], ordered = [:a,:b,:c])
```
"""
struct Levels{K} <: Stateless
  levelspec::K
  ordered::Vector{Symbol}
end

Levels(pairs::Pair{K}...; ordered::AbstractVector{K}=Symbol[]) where {K <: Symbol} =
  Levels(NamedTuple(pairs), ordered)

Levels(pairs::Pair{K}...; ordered::AbstractVector{K}=String[]) where {K <: AbstractString} =
  Levels(NamedTuple(Symbol(k) => v for (k,v) in pairs), Symbol.(ordered))

isrevertible(transform::Levels) = true

# when the col is already a categorical array and wanna change levels and order
categorify(l::AbstractVector, x::CategoricalVector, o) = levels(x), categorical(x, levels=l, ordered=o) 

# when the col is normal array and want to change to categorical array
categorify(l, x::AbstractVector, o) = unwrap, categorical(x,levels=l, ordered=o) 

# when the col is not need for change or convert back to normal array
categorify(f::Function, x::AbstractVector, o) = o ? (levels(x), categorical(x, ordered=true)) : (f, f.(x))

function apply(transform::Levels,table)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  newlevels = transform.levelspec
  caches = Vector{Union{Vector,Function}}()
  ncols = map(names) do nm
    x = Tables.getcolumn(cols, nm)
    l = get(newlevels, nm, identity)
    o = in(nm,transform.ordered)
    cache, newx = categorify(l, x, o)
    push!(caches, cache)
    newx
  end
  
  𝒯 = (; zip(names, ncols)...)
  newtable = 𝒯 |> Tables.materializer(table)
  
  newtable, caches
end

function revert(transform::Levels, newtable, caches)
  @assert isrevertible(transform)

  cols = Tables.columns(newtable)
  names = Tables.columnnames(cols)

  ocols = map(zip(caches, names)) do (func, nm)
    x = Tables.getcolumn(cols, nm)
    last(categorify(func,x,false))
  end
  
  𝒯 = (; zip(names, ocols)...)
  𝒯 |> Tables.materializer(newtable)
end
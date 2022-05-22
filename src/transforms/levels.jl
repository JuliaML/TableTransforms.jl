"""
    Levels(:a => ["yes,"no"])

Return a copy of the table with specified levels and orders for categorical columns
allowing only changing the order of the column

# Examples

```julia
Levels(:a => ["yes,"no"], :c => [1,2,4], :d = ["a","b","c"])
Levels("a" => ["yes","no"], "c" => [1,2,4], ordered= ["a","c"])
Levels(:a => ["yes","no"], :c => [1,2,4], :d => [1,23,5,7] ,ordered = [:a,:b,:c])
```
"""

@kwdef struct Levels{K} <: Stateless
	levelspec::K
  ordered::AbstractVector{Symbol}
end
#should work more on constructors
Levels(pairs::Pair{K}...; ordered::AbstractVector{K}=Symbol[]) where {K <: Symbol} =
  Levels(NamedTuple(pairs), ordered)

Levels(pairs::Pair{K}...; ordered::AbstractVector{K}=String[]) where {K <: AbstractString} =
  Levels(NamedTuple(Symbol(k) => v for (k,v) in pairs), Symbol.(ordered))

Levels(pairs::Pair{K}...) where {K <: Symbol} =
  Levels(NamedTuple(pairs),Symbol[])

Levels(pairs::Pair{K}...) where {K <: AbstractString} =
  Levels(NamedTuple(Symbol(k) => v for (k,v) in pairs),Symbol[])



isrevertible(transform::Levels) = true
# handle three cases
#1. when the col is already a categorical array and wanna change levels and order
categorify(levels::AbstractVector, x::CategoricalVector,ordered::Bool) = levels(x) , categorical(x,levels = levels ,ordered=ordered) 
#2. when the col is normal array and want to change to categorical array
categorify(levels::AbstractVector, x::AbstractVector,ordered::Bool) = unwrap, categorical(x,levels = levels,ordered=ordered) 
#3. when the col is not need for change or convert back to normal array
categorify(func::Function, x::AbstractVector,ordered::Bool) = ordered ? (levels(x), categorical(x, ordered=true)) : (func , func.(x))


function apply(transform::Levels,table)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  levels = transform.levelspec
  #should I pre-allocate the caches vector
  caches = []
  ncols = map(names) do nm
    x = Tables.getcolumn(cols, nm)
    cat_level = get(levels, nm, identity)
    ordered = in(nm,transform.ordered)
    cache, new_x = categorify(cat_level, x,ordered)
    push!(caches, cache)
    new_x
  end
  
  𝒯 = (; zip(names, ncols)...)
  newtable = 𝒯 |> Tables.materializer(table)
  
  return newtable, caches
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
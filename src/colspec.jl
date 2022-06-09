# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# types used to select a column
const ColSelector = Union{Symbol,Integer,AbstractString}

"""
    ColSpec  

`ColSpec` is a union of types used to filter columns. 
The `ColSpec` type together with the `ColSelector` union type and 
the `choose` function form the ColSpec interface.

To implement the ColSpec interface, the following steps must be performed:

1. add colspec fied:
```julia
struct MyTransform{S<:ColSpec,#= other type params =#}
  colspec::S
  # other fileds
end
```
2. use `choose(colspec, names)` function in apply:
```julia
function apply(transform::MyTransform, table)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  # selected column names
  snames = choose(transform.colspec, names)
  # code...
end
```

If you need to create constructors that accept 
individual column selectors use the `ColSelector` type. Example:
```julia
function MyTransform(args::T...) where {T<:ColSelector}
  # code...
end
```
"""
const ColSpec = Union{Vector{T},NTuple{N,T},Regex,Colon,Nothing} where {N,T<:ColSelector}

"""
    choose(colspec::ColSpec, names) -> Vector{Symbol}

Choose column `names` using `colspec`.

# Examples

```julia
julia> names = (:a, :b, :c, :d, :e, :f);

julia> choose(["a", "c", "e"], names)
3-element Vector{Symbol}:
 :a
 :c
 :e

julia> choose((1, 3, 5), names)
3-element Vector{Symbol}:
 :a
 :c
 :e

julia> choose(r"[ace]", names)
3-element Vector{Symbol}:
 :a
 :c
 :e

julia> choose(:, names)
6-element Vector{Symbol}:
  :a
  :b
  :c
  :d
  :e
  :f

julia> choose(nothing, names)
Symbol[]
```
"""
function choose(colspec::Vector{Symbol}, names)
  # validate columns
  @assert !isempty(colspec) "Invalid column selection."
  @assert colspec ⊆ names "Invalid column selection."
  return colspec
end

choose(colspec::Vector{<:AbstractString}, names) = 
  choose(Symbol.(colspec), names)

choose(colspec::Vector{<:Integer}, names::Vector) = 
  choose(names[colspec], names)

choose(colspec::Vector{<:Integer}, names::Tuple) = 
  choose(colspec, collect(names))

choose(colspec::NTuple{N,<:ColSelector}, names) where {N} =
  choose(collect(colspec), names)

function choose(colspec::Regex, names::Vector)
  fnames = filter(n -> occursin(colspec, String(n)), names)
  choose(fnames, names)
end

choose(colspec::Regex, names::Tuple) = 
  choose(colspec, collect(names))

choose(::Colon, names::Vector) = names
choose(::Colon, names::Tuple) = collect(names)
choose(::Nothing, names) = Symbol[]

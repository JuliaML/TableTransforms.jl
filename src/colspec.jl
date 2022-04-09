# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# types used to select a column
const ColSelector = Union{Symbol,Integer,AbstractString}

"""
    ColSpec  

`ColSpec` is a union of types used to filter columns. 
The `ColSpec` type together with the `ColSelector` union type and 
the `_filter` internal function form the ColSpec interface.

To implement the ColSpec interface, the following steps must be performed:

1. add colspec fied:
```julia
struct MyTransform{S<:ColSpec,#= other type params =#}
  colspec::S
  # other fileds
end
```
2. use `_filter(colspec, cols)` internal function in apply:
```julia
function apply(transform::MyTransform, table)
  allcols = Tables.columnnames(table)
  # selected columns
  cols = _filter(transform.colspec, allcols)
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
const ColSpec = Union{Vector{T},NTuple{N,T},Regex,Colon} where {N,T<:ColSelector}

# filter table columns using colspec
function _filter(colspec::Vector{Symbol}, cols)
  # validate columns
  @assert !isempty(colspec) "Invalid column selection."
  @assert colspec ⊆ cols "Invalid column selection."
  return colspec
end

_filter(colspec::Vector{<:AbstractString}, cols) = 
  _filter(Symbol.(colspec), cols)

_filter(colspec::Vector{<:Integer}, cols::Vector) = 
  _filter(cols[colspec], cols)

_filter(colspec::Vector{<:Integer}, cols::Tuple) = 
  _filter(colspec, collect(cols))

_filter(colspec::NTuple{N,<:ColSelector}, cols) where {N} =
  _filter(collect(colspec), cols)

function _filter(colspec::Regex, cols::Vector)
  fcols = filter(col -> occursin(colspec, String(col)), cols)
  _filter(fcols, cols)
end

_filter(colspec::Regex, cols::Tuple) = 
  _filter(colspec, collect(cols))

_filter(::Colon, cols::Vector) = cols
_filter(::Colon, cols::Tuple) = collect(cols)

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
2. use `_filter(colspec, names)` internal function in apply:
```julia
function apply(transform::MyTransform, table)
  names = Tables.columnnames(table)
  # selected column names
  snames = _filter(transform.colspec, names)
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
function _filter(colspec::Vector{Symbol}, names)
  # validate columns
  @assert !isempty(colspec) "Invalid column selection."
  @assert colspec ⊆ names "Invalid column selection."
  return colspec
end

_filter(colspec::Vector{<:AbstractString}, names) = 
  _filter(Symbol.(colspec), names)

_filter(colspec::Vector{<:Integer}, names::Vector) = 
  _filter(names[colspec], names)

_filter(colspec::Vector{<:Integer}, names::Tuple) = 
  _filter(colspec, collect(names))

_filter(colspec::NTuple{N,<:ColSelector}, names) where {N} =
  _filter(collect(colspec), names)

function _filter(colspec::Regex, names::Vector)
  fnames = filter(col -> occursin(colspec, String(col)), names)
  _filter(fnames, names)
end

_filter(colspec::Regex, names::Tuple) = 
  _filter(colspec, collect(names))

_filter(::Colon, names::Vector) = names
_filter(::Colon, names::Tuple) = collect(names)

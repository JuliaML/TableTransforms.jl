# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# union of types used to select a column
const ColSelector = Union{Symbol, Integer, AbstractString}
# union of types used to filter columns
const ColSpec = Union{Vector{T}, NTuple{N,T}, Regex, Colon} where {N,T<:ColSelector}

# filter table columns using colspec
# note: _filter function always returns a Vector{Symbol},
# because Vector is more flexible than Tuple.
function _filter(colspec::Vector{Symbol}, allcols::Vector)
  # validate columns
  @assert !isempty(colspec) "Invalid column selection."
  @assert colspec ⊆ allcols "Invalid column selection."
  return colspec
end

_filter(colspec::Vector{<:Integer}, allcols::Vector) = 
  _filter(allcols[colspec], allcols)

_filter(colspec::Vector{<:AbstractString}, allcols::Vector) = 
  _filter(Symbol.(colspec), allcols)

_filter(colspec::NTuple{N,<:ColSelector}, allcols::Vector) where {N} =
  _filter(collect(colspec), allcols)

function _filter(colspec::Regex, allcols::Vector)
  cols = filter(col -> occursin(colspec, String(col)), allcols)
  _filter(cols, allcols)
end

_filter(::Colon, allcols::Vector) = allcols

_filter(colspec::ColSpec, allcols::Tuple) = 
  _filter(colspec, collect(allcols))

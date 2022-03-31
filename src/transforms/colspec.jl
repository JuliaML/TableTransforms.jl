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
function _filter(colspec::Vector{Symbol}, allcols)
  # validate columns
  @assert !isempty(colspec) "Invalid column selection."
  @assert colspec ⊆ allcols "Invalid column selection."
  return colspec
end

_filter(colspec::Vector{<:Integer}, allcols) = 
  _filter(allcols[colspec], allcols)

_filter(colspec::Vector{<:AbstractString}, allcols) = 
  _filter(Symbol.(colspec), allcols)

_filter(colspec::NTuple{N,<:ColSelector}, allcols) where {N} =
  _filter(collect(colspec), allcols)

function _filter(colspec::Regex, allcols)
  cols = filter(col -> occursin(colspec, String(col)), allcols)
  _filter(cols, allcols)
end

# special case returned by _filter(colspec::Regex, allcols)
_filter(::Tuple{}, allcols) = _filter(Symbol[], allcols)

_filter(::Colon, allcols::Vector) = allcols
_filter(::Colon, allcols::Tuple) = collect(allcols)

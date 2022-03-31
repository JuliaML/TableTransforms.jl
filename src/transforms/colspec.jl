# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# union of types used to select a column
const ColSelector = Union{Symbol, Integer, AbstractString}
# union of types used to filter columns
const ColSpec = Union{Vector{T}, NTuple{N,T}, Regex, Colon} where {N,T<:ColSelector}

# _filter(colspec, allcols)
# filter table columns using colspec
#
# note 1: _filter function always returns a Vector{Symbol},
# because Vector is more flexible than Tuple.
#
# note 2: allcols can be of type Vector or Tuple,
# in some cases it doesn't matter, but in others it does.
#
# note 3: all other methods of the function convert their arguments
# to call the method below (main method), except the last one.

# _filter(::Vector{Symbol}, allcols) - main method
# second argument can be a Vector or Tuple
function _filter(colspec::Vector{Symbol}, allcols)
  # validate columns
  @assert !isempty(colspec) "Invalid column selection."
  @assert colspec ⊆ allcols "Invalid column selection."
  return colspec
end

# _filter(::Vector{<:AbstractString}, allcols)
# second argument can be a Vector or Tuple
_filter(colspec::Vector{<:AbstractString}, allcols) = 
  _filter(Symbol.(colspec), allcols)

# _filter(::Vector{<:Integer}, allcols)
# the second argument must be a Vector
_filter(colspec::Vector{<:Integer}, allcols::Vector) = 
  _filter(allcols[colspec], allcols)

_filter(colspec::Vector{<:Integer}, allcols::Tuple) = 
  _filter(colspec, collect(allcols))

# _filter(::NTuple{N,<:ColSelector}, allcols)
# convert colspec to Vector
_filter(colspec::NTuple{N,<:ColSelector}, allcols) where {N} =
  _filter(collect(colspec), allcols)

# _filter(::Regex, allcols)
# the second argument must be a Vector
function _filter(colspec::Regex, allcols::Vector)
  cols = filter(col -> occursin(colspec, String(col)), allcols)
  _filter(cols, allcols)
end

_filter(colspec::Regex, allcols::Tuple) = 
  _filter(colspec, collect(allcols))

# _filter(::Colon, allcols)
# the second argument must be a Vector
_filter(::Colon, allcols::Vector) = allcols
_filter(::Colon, allcols::Tuple) = collect(allcols)

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# types used to select a column
const ColSelector = Union{Symbol, Integer, AbstractString}
# types used to filter columns
# const ColSpec = Union{Vector{T}, NTuple{N,T}, Regex, Colon} where {N,T<:ColSelector}

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

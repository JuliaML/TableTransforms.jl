# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# union of types used to select a column
const ColSelector = Union{Symbol, Integer, AbstractString}
# union of types used to filter columns
const ColSpec = Union{Vector{T}, NTuple{N,T}, Regex, Colon} where {N,T<:ColSelector}

# filter table columns using colspec
_filter(colspec::Vector{Symbol}, allcols) = colspec
_filter(colspec::Vector{<:Integer}, allcols) = allcols[colspec]
_filter(colspec::Vector{<:AbstractString}, allcols) = Symbol.(colspec)
_filter(colspec::NTuple{N,<:ColSelector}, allcols) where {N} =
  _filter(collect(colspec), allcols)
_filter(colspec::Regex, allcols) = 
  filter(col -> occursin(colspec, String(col)), allcols)
_filter(::Colon, allcols) = allcols

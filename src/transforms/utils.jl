# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

const ColSelector = Union{Symbol, Integer, AbstractString}
const VecOrTuple{T} = Union{Vector{T}, NTuple{N, T}} where {T, N}
const ColSpec{T} = Union{VecOrTuple{T}, Regex, Colon} where {T<:ColSelector}

_select(colspec::Vector{Symbol}, allcols) = colspec
_select(colspec::Vector{<:AbstractString}, allcols) = Symbol.(colspec)
_select(colspec::Vector{<:Integer}, allcols) = allcols[colspec]
_select(colspec::NTuple{N, <:ColSelector}, allcols) where {N} =
    _select(collect(colspec), allcols)
_select(colspec::Regex, allcols) = 
  filter(col -> occursin(colspec, String(col)), allcols)
_select(::Colon, allcols) = allcols

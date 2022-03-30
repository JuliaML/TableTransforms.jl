# ------------------------------------------------------------------ 
# Licensed under the MIT License. See LICENSE in the project root. 
# ------------------------------------------------------------------ 
 
# union of types used to select a column 
const ColSelector = Union{Symbol, Integer, AbstractString} 
const VecOrTuple{T} = Union{Vector{T}, NTuple{N,T}} where {N}
# union of types used to filter columns 
const ColSpec = Union{VecOrTuple{T}, Regex, Colon} where {T<:ColSelector} 

# _filter
# filter table columns using colspec  
function _filter(colspec::VecOrTuple{Symbol}, allcols)  
  # validate column selection 
  @assert !isempty(colspec) "Invalid column selection" 
  @assert colspec ⊆ allcols "Invalid column selection" 
  return colspec 
end
 
_filter(colspec::VecOrTuple{<:Integer}, allcols) =  
  _filter(allcols[colspec], allcols)

_filter(colspec::VecOrTuple{<:AbstractString}, allcols) =  
  _filter(Symbol.(colspec), allcols)

_filter(::Colon, allcols) = allcols
 
function _filter(colspec::Regex, allcols)
  cols = filter(col -> occursin(colspec, String(col)), allcols)
  _filter(cols, allcols)
end

# _indexin
_indexin(a, b) = Union{Nothing,Int}[findfirst(==(x), b) for x in a]

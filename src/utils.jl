# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

_dropunit(x) = _dropunit(x, nonmissingtype(eltype(x)))
_dropunit(x, ::Type{Q}) where {Q<:AbstractQuantity} = (map(ustrip, x), unit(Q))
_dropunit(x, ::Type) = (x, NoUnits)

_withunit(x, ::typeof(NoUnits)) = x
_withunit(x, u::Units) = map(v -> v * u, x)

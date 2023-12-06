# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    ILR([refvar])

Isometric log-ratio transform.

Optionally, specify the reference variable `refvar` for the ratios.
Default to the last column of the input table.
"""
struct ILR{T<:Union{Symbol,Nothing}} <: LogRatio
  refvar::T
end

ILR() = ILR(nothing)

refvar(transform::ILR, names) = isnothing(transform.refvar) ? last(names) : transform.refvar

newvars(::ILR, names) = Symbol.(:ILR, 1:(length(names) - 1))

applymatrix(::ILR, X) = mapslices(ilr ∘ Composition, X, dims=2)

revertmatrix(::ILR, Y) = mapslices(CoDa.components ∘ ilrinv, Y, dims=2)

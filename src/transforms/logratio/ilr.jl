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

newvars(::ILR, names) = collect(names)[begin:(end - 1)]

oldvars(::ILR, names, rvar) = [collect(names); rvar]

applymatrix(::ILR, X) = mapslices(ilr ∘ Composition, X, dims=2)

revertmatrix(::ILR, Y) = mapslices(components ∘ ilrinv, Y, dims=2)

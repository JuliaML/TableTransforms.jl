# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    ALR([refvar])

Additive log-ratio transform.

Optionally, specify the reference variable `refvar` for the ratios.
Default to the last column of the input table.
"""
struct ALR{T<:Union{Symbol,Nothing}} <: LogRatio
  refvar::T
end

ALR() = ALR(nothing)

refvar(transform::ALR, names) = isnothing(transform.refvar) ? last(names) : transform.refvar

newvars(::ALR, names) = collect(names)[begin:(end - 1)]

oldvars(::ALR, names, rvar) = [collect(names); rvar]

applymatrix(::ALR, X) = mapslices(alr ∘ Composition, X, dims=2)

revertmatrix(::ALR, Y) = mapslices(components ∘ alrinv, Y, dims=2)

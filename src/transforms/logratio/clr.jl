# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    CLR()

Centered log-ratio transform.
"""
struct CLR <: LogRatio end

refvar(::CLR, names) = last(names)

newvars(::CLR, names) = collect(names)

oldvars(::CLR, names, rvar) = collect(names)

applymatrix(::CLR, X) = mapslices(clr ∘ Composition, X, dims=2)

revertmatrix(::CLR, Y) = mapslices(components ∘ clrinv, Y, dims=2)

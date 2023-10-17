# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    Remainder([total])

The transform that takes a table with columns `x₁, x₂, …, xₙ`
and returns a new table with an additional column containing the
remainder value `xₙ₊₁ = total .- (x₁ + x₂ + ⋯ + xₙ)` If the `total`
value is not specified, then default to the maximum sum across rows.

See also [`Closure`](@ref).
"""
struct Remainder{T<:Union{Number,Nothing}} <: FeatureTransform
  total::T
end

Remainder() = Remainder(nothing)

isrevertible(::Type{<:Remainder}) = true

assertions(::Remainder) = [SciTypeAssertion{Continuous}()]

function applyfeat(transform::Remainder, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols) |> collect

  # design matrix
  X = Tables.matrix(feat)

  # sum of each row
  S = sum(X, dims=2)

  # retrieve the total
  total = if isnothing(transform.total)
    maximum(S)
  else
    t = convert(eltype(X), transform.total)
    # make sure that the total is valid
    @assert all(≤(t), S) "the sum for each row must be less than total"
    t
  end

  # create a column with the remainder
  Z = [X (total .- S)]

  # create new column name
  rname = :remainder
  while rname ∈ names
    rname = Symbol(rname, :_)
  end
  push!(names, rname)

  # table with new column
  𝒯 = (; zip(names, eachcol(Z))...)
  newfeat = 𝒯 |> Tables.materializer(feat)

  newfeat, (total, rname)
end

function revertfeat(::Remainder, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)
  
  _, rname = fcache
  onames = setdiff(names, [rname])
  𝒯 = (; (nm => Tables.getcolumn(cols, nm) for nm in onames)...)
  𝒯 |> Tables.materializer(newfeat)
end

function reapplyfeat(::Remainder, feat, fcache)
  total, _ = fcache
  newfeat, _ = applyfeat(Remainder(total), feat, nothing)
  newfeat
end

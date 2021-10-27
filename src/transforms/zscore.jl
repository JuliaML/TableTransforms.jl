# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    ZScore()

The z-score (a.k.a. normal score) of `x` with mean `μ` and
standard deviation `σ` is the value `(x .- μ) ./ σ`.
"""
struct ZScore <: Transform end

isinvertible(::Type{ZScore}) = true

function forward(::ZScore, table)
  # sanity checks
  sch = schema(table)
  names = sch.names
  types = sch.scitypes
  @assert all(T <: Continuous for T in types) "columns must hold continuous variables"

  # original columns
  cols = Tables.columns(table)

  # normal scores and stats
  vals = map(names) do name
    x = Tables.getcolumn(table, name)
    μ = mean(x)
    σ = std(x, mean=μ)
    z = ((x .- μ) ./ σ)
    z, (μ=μ, σ=σ)
  end

  # table with normal scores
  𝒯 = (; zip(names, first.(vals))...)
  ztable = 𝒯 |> Tables.materializer(table)

  # vector with stats
  stats = last.(vals)

  # return scores and stats
  ztable, stats
end

function backward(::ZScore, newtable, cache)
  names = Tables.columnnames(newtable)
  @assert length(names) == length(cache) "invalid cache for table"

  # modified columns
  cols  = Tables.columns(newtable)

  # original columns
  oldcols = map(1:length(names)) do i
    x = Tables.getcolumn(cols, i)
    μ, σ = cache[i]
    μ .+ σ*x
  end

  # table with original columns
  𝒯 = (; zip(names, oldcols)...)
  𝒯 |> Tables.materializer(newtable)
end
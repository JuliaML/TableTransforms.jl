# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Detrend()

The transform that removes trends in the variables.
"""
struct Detrend <: Transform end

isrevertible(::Type{Detrend}) = true

function apply(::Detrend, table)
  # sanity checks
  check_continuous(table)

  # variable names
  names = schema(table).names

  # normal scores and stats
  vals = map(names) do name
    x = Tables.getcolumn(table, name)
    μ = mean(x)
    z = (x .- μ)
    z, μ
  end

  # table with normal scores
  𝒯 = (; zip(names, first.(vals))...)
  ztable = 𝒯 |> Tables.materializer(table)

  # vector with stats
  stats = last.(vals)

  # return scores and stats
  ztable, stats
end

function revert(::Detrend, newtable, cache)
  names = Tables.columnnames(newtable)
  @assert length(names) == length(cache) "invalid cache for table"

  # modified columns
  cols = Tables.columns(newtable)

  # original columns
  oldcols = map(1:length(names)) do i
    x = Tables.getcolumn(cols, i)
    μ = cache[i]
    μ .+ x
  end

  # table with original columns
  𝒯 = (; zip(names, oldcols)...)
  𝒯 |> Tables.materializer(newtable)
end
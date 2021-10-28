# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Center()

The transform that removes the mean of the variables.
"""
struct Center <: Transform end

isrevertible(::Type{Center}) = true

function apply(::Center, table)
  # sanity checks
  assert_continuous(table)

  # center the columns
  colwise(table) do x
    μ = mean(x)
    z = (x .- μ)
    z, μ
  end
end

function revert(::Center, newtable, cache)
  # transformed columns
  names = Tables.columnnames(newtable)
  cols  = Tables.columns(newtable)

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
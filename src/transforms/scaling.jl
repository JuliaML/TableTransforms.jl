# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Scaling(; low=0.25, high=0.75)

The scaling transform of `x` is the value `(x .- xl) ./ (xh .- xl))`
where `xl = quantile(x, low)` and `xh = quantile(x, high)`.
"""
struct Scaling <: Transform
  low::Float64
  high::Float64
end

Scaling(; low=0.25, high=0.75) = Scaling(low, high)

isinvertible(::Type{<:Scaling}) = true

function forward(transform::Scaling, table)
  # sanity checks
  sch = schema(table)
  names = sch.names
  types = sch.scitypes
  @assert all(T <: Continuous for T in types) "columns must hold continuous variables"

  # scaled values and factors
  vals = map(names) do name
    x = Tables.getcolumn(table, name)
    levels = (transform.low, transform.high)
    xl, xh = quantile(x, levels)
    z = (x .- xl) ./ (xh .- xl)
    z, (xl=xl, xh=xh)
  end

  # table with scaled values
  𝒯 = (; zip(names, first.(vals))...)
  newtable = 𝒯 |> Tables.materializer(table)

  # vector with scaling factors
  factors = last.(vals)

  # return scaled table and factors
  newtable, factors
end

function backward(transform::Scaling, newtable, cache)
  names = Tables.columnnames(newtable)
  @assert length(names) == length(cache) "invalid cache for table"

  # modified columns
  cols = Tables.columns(newtable)

  # original columns
  oldcols = map(1:length(names)) do i
    x = Tables.getcolumn(cols, i)
    xl, xh = cache[i]
    xl .+ (xh .- xl)*x
  end

  # table with original columns
  𝒯 = (; zip(names, oldcols)...)
  𝒯 |> Tables.materializer(newtable)
end

"""
    MinMax()

The transform that is equivalent to `Scaling(low=0, high=1)`.
"""
MinMax() = Scaling(low=0.0, high=1.0)

"""
    Interquartile()

The transform that is equivalent to `Scaling(low=0.25, high=0.75)`.
"""
Interquartile() = Scaling(low=0.25, high=0.75)

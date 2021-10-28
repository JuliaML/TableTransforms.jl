# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Scale(; low=0.25, high=0.75)

The scale transform of `x` is the value `(x .- xl) ./ (xh .- xl))`
where `xl = quantile(x, low)` and `xh = quantile(x, high)`.
"""
struct Scale <: Transform
  low::Float64
  high::Float64
end

Scale(; low=0.25, high=0.75) = Scale(low, high)

isrevertible(::Type{Scale}) = true

function apply(transform::Scale, table)
  assert_continuous(table)
  colwise(table) do x
    levels = (transform.low, transform.high)
    xl, xh = quantile(x, levels)
    z = (x .- xl) ./ (xh .- xl)
    z, (xl=xl, xh=xh)
  end
end

function revert(::Scale, newtable, cache)
  # transformed columns
  names = Tables.columnnames(newtable)
  cols  = Tables.columns(newtable)

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

The transform that is equivalent to `Scale(low=0, high=1)`.
"""
MinMax() = Scale(low=0.0, high=1.0)

"""
    Interquartile()

The transform that is equivalent to `Scale(low=0.25, high=0.75)`.
"""
Interquartile() = Scale(low=0.25, high=0.75)

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Unit(unit)

TODO

    Unit(cols₁ => unit₁, cols₂ => unit₂, ..., colsₙ => unitₙ)

TODO

# Examples

```julia
```
"""
struct Unit <: StatelessFeatureTransform
  selectors::Vector{ColumnSelector}
  units::Vector{Units}
end

Unit() = throw(ArgumentError("cannot create Unit transform without arguments"))

Unit(unit::Units) = Unit([AllSelector()], [unit])

Unit(pairs::Pair...) = Unit(collect(selector.(first.(pairs))), collect(last.(pairs)))

isrevertible(::Type{<:Unit}) = true

function applyfeat(transform::Unit, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)

  selectors = transform.selectors
  units = transform.units
  pairs = mapreduce(vcat, selectors, units) do selector, u
    snames = selector(names)
    snames .=> u
  end
  unitdict = Dict(pairs) 

  tuples = map(names) do name
    x = Tables.getcolumn(cols, name)
    if haskey(unitdict, name)
      u = unitdict[name]
      y = uconvert.(u, x)
      (y, unit(eltype(x)))
    else
      (x, nothing)
    end
  end

  columns = first.(tuples)
  ounits = last.(tuples)

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)
  newfeat, ounits
end

function revertfeat(::Unit, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)

  ounits = fcache
  columns = map(names, ounits) do name, u
    x = Tables.getcolumn(cols, name)
    isnothing(u) ? x : uconvert.(u, x)
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

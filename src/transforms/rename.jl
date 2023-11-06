# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Rename(:col₁ => :newcol₁, :col₂ => :newcol₂, ..., :colₙ => :newcolₙ)

The transform that renames `col₁`, `col₂`, ..., `colₙ`
to `newcol₁`, `newcol₂`, ..., `newcolₙ`.

# Examples

```julia
Rename(1 => :x, 3 => :y)
Rename(:a => :x, :c => :y)
Rename("a" => "x", "c" => "y")
```
"""
struct Rename{S<:ColumnSelector} <: StatelessFeatureTransform
  selector::S
  newnames::Vector{Symbol}
  function Rename(selector::S, newnames) where {S<:ColumnSelector}
    if !allunique(newnames) 
      throw(AssertionError("new names must be unique"))
    end
    new{S}(selector, newnames)
  end
end

Rename(pairs::Pair{C,Symbol}...) where {C<:Column} = Rename(selector(first.(pairs)), collect(last.(pairs)))

Rename(pairs::Pair{C,S}...) where {C<:Column,S<:AbstractString} =
  Rename(selector(first.(pairs)), collect(Symbol.(last.(pairs))))

isrevertible(::Type{<:Rename}) = true

function applyfeat(transform::Rename, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = transform.selector(names)
  if transform.newnames ⊆ setdiff(names, snames)
    throw(AssertionError("duplicate names"))
  end

  mapnames = Dict(zip(snames, transform.newnames))
  newnames = [get(mapnames, nm, nm) for nm in names]
  columns = [Tables.getcolumn(cols, nm) for nm in names]

  𝒯 = (; zip(newnames, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)
  newfeat, names
end

function revertfeat(::Rename, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)
  columns = [Tables.getcolumn(cols, nm) for nm in names]

  𝒯 = (; zip(fcache, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

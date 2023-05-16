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
struct Rename{S<:ColSpec} <: StatelessFeatureTransform
  colspec::S
  newnames::Vector{Symbol}
  function Rename(colspec::S, newnames) where {S<:ColSpec}
    @assert allunique(newnames) "new names must be unique"
    new{S}(colspec, newnames)
  end
end

Rename(pairs::Pair{T,Symbol}...) where {T<:Col} = Rename(colspec(first.(pairs)), collect(last.(pairs)))

Rename(pairs::Pair{T,S}...) where {T<:Col,S<:AbstractString} =
  Rename(colspec(first.(pairs)), collect(Symbol.(last.(pairs))))

isrevertible(::Type{<:Rename}) = true

function applyfeat(transform::Rename, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = choose(transform.colspec, names)
  @assert transform.newnames ⊈ setdiff(names, snames) "duplicate names"

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

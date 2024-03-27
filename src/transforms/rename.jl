# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Rename(:col₁ => :newcol₁, :col₂ => :newcol₂, ..., :colₙ => :newcolₙ)
    Rename([:col₁ => :newcol₁, :col₂ => :newcol₂, ..., :colₙ => :newcolₙ])

Renames the columns `col₁`, `col₂`, ..., `colₙ` to `newcol₁`, `newcol₂`, ..., `newcolₙ`.

    Rename(fun)

Renames the table columns using the modification function `fun` that takes a 
string as input and returns another string with the new name.

# Examples

```julia
Rename(1 => :x, 3 => :y)
Rename(:a => :x, :c => :y)
Rename("a" => "x", "c" => "y")
Rename([1 => "x", 3 => "y"])
Rename([:a => "x", :c => "y"])
Rename(["a", "c"] .=> [:x, :y])
Rename(nm -> nm * "_suffix")
```
"""
struct Rename{S<:ColumnSelector,N} <: StatelessFeatureTransform
  selector::S
  newnames::N
  function Rename(selector::S, newnames::N) where {S<:ColumnSelector,N}
    if newnames isa AbstractVector
      _assert(allunique(newnames), "new names must be unique")
    end
    new{S,N}(selector, newnames)
  end
end

Rename() = throw(ArgumentError("cannot create Rename transform without arguments"))

Rename(fun) = Rename(AllSelector(), fun)

Rename(pairs::Pair{C,Symbol}...) where {C<:Column} = Rename(selector(first.(pairs)), collect(last.(pairs)))

Rename(pairs::Pair{C,S}...) where {C<:Column,S<:AbstractString} =
  Rename(selector(first.(pairs)), collect(Symbol.(last.(pairs))))

Rename(pairs::AbstractVector{Pair{C,Symbol}}) where {C<:Column} = Rename(selector(first.(pairs)), last.(pairs))

Rename(pairs::AbstractVector{Pair{C,S}}) where {C<:Column,S<:AbstractString} =
  Rename(selector(first.(pairs)), Symbol.(last.(pairs)))

isrevertible(::Type{<:Rename}) = true

_newnames(newnames::AbstractVector{Symbol}, snames) = newnames
_newnames(fun, snames) = [Symbol(fun(string(name))) for name in snames]

function applyfeat(transform::Rename, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = transform.selector(names)
  tnames = _newnames(transform.newnames, snames)
  _assert(tnames ⊈ setdiff(names, snames), "duplicate names")

  mapnames = Dict(zip(snames, tnames))
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

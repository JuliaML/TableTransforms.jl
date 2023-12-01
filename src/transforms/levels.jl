# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Levels(col₁ => levels₁, col₂ => levels₂, ..., colₙ => levelsₙ; ordered=nothing)

Convert columns `col₁`, `col₂`, ..., `colₙ` to categorical arrays with given levels `levels₁`, `levels₂`, ..., `levelsₙ`.
Optionally, specify which columns are `ordered`.

# Examples

```julia
Levels(1 => 1:3, 2 => ["a", "b"], ordered=r"a")
Levels(:a => 1:3, :b => ["a", "b"], ordered=[:a])
Levels("a" => 1:3, "b" => ["a", "b"], ordered=["b"])
```
"""
struct Levels{S<:ColumnSelector,O<:ColumnSelector,L} <: StatelessFeatureTransform
  selector::S
  ordered::O
  levels::L
end

Levels(pairs::Pair{C}...; ordered=nothing) where {C<:Column} =
  Levels(selector(first.(pairs)), selector(ordered), last.(pairs))

Levels(; kwargs...) = throw(ArgumentError("cannot create Levels transform without arguments"))

assertions(transform::Levels) = [SciTypeAssertion(transform.selector, scitype=Categorical)]

isrevertible(::Type{<:Levels}) = true

_revfun(x) = y -> Array(y)
function _revfun(x::CategoricalArray)
  l, o = levels(x), isordered(x)
  y -> categorical(y, levels=l, ordered=o)
end

function applyfeat(transform::Levels, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = transform.selector(names)
  ordered = transform.ordered(snames)
  leveldict = Dict(zip(snames, transform.levels))

  results = map(names) do name
    x = Tables.getcolumn(cols, name)

    if name ∈ snames
      o = name ∈ ordered
      l = leveldict[name]
      y = categorical(x, levels=l, ordered=o)
      revfun = _revfun(x)
      y, revfun
    else
      x, identity
    end
  end

  columns, fcache = first.(results), last.(results)

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)

  newfeat, fcache
end

function revertfeat(::Levels, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)

  columns = map(names, fcache) do name, revfun
    y = Tables.getcolumn(cols, name)
    revfun(y)
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

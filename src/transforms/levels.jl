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

assertions(transform::Levels) = [ColumnTypeAssertion{CategoricalArray}(transform.selector)]

isrevertible(::Type{<:Levels}) = true

function applyfeat(transform::Levels, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = transform.selector(names)
  ordered = transform.ordered(snames)
  tlevels = transform.levels

  results = map(names) do nm
    x = Tables.getcolumn(cols, nm)

    if nm ∈ snames
      o = nm ∈ ordered
      l = tlevels[findfirst(==(nm), snames)]
      y = categorical(x, levels=l, ordered=o)

      xl, xo = levels(x), isordered(x)
      revfunc = y -> categorical(y, levels=xl, ordered=xo)
    else
      y, revfunc = x, identity
    end

    y, revfunc
  end

  columns, fcache = first.(results), last.(results)

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)

  newfeat, fcache
end

function revertfeat(::Levels, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)

  columns = map(names, fcache) do nm, revfunc
    x = Tables.getcolumn(cols, nm)
    revfunc(x)
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

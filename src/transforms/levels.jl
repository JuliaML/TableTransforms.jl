# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Levels(col₁ => levels₁, col₂ => levels₂, ..., colₙ => levelsₙ; ordered=nothing)

Make selected columns `col₁`, `col₂`, ..., `colₙ` categorical by specifying the levels of each one.
`ordered` keyword argument can be a tuple, vector or regex that selects the columns where `ordered=true`.

# Examples

```julia
Levels(1 => 1:3, 2 => ["a", "b"], ordered=r"a")
Levels(:a => 1:3, :b => ["a", "b"], ordered=[:a])
Levels("a" => 1:3, "b" => ["a", "b"], ordered=["b"])
```
"""
struct Levels{S<:ColSpec,O<:ColSpec,L} <: Stateless
  colspec::S
  ordered::O
  levels::L
end

Levels(pairs::Pair{T}...; ordered::ColSpec=nothing) where {T<:ColSelector} =
  Levels(first.(pairs), ordered, last.(pairs))

Levels(; kwargs...) = throw(ArgumentError("Cannot create a Levels object without arguments."))

isrevertible(transform::Levels) = true

_categorical(x::AbstractVector, o, l) =
  categorical(x, ordered=o, levels=l), y -> unwrap.(y)

function _categorical(x::CategoricalArray, o, l)
  xo, xl = isordered(x), levels(x)
  revfunc = y -> categorical(y, ordered=xo, levels=xl)
  categorical(x, ordered=o, levels=l), revfunc
end

function apply(transform::Levels, table)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  snames = choose(transform.colspec, names)
  ordered = choose(transform.ordered, snames)
  levels = transform.levels
  
  results = map(names) do nm
    x = Tables.getcolumn(cols, nm)
    if nm ∈ snames
      o = nm ∈ ordered
      l = levels[findfirst(==(nm), snames)]
      return _categorical(x, o, l)
    end
    x, identity
  end

  columns, cache = first.(results), last.(results)

  𝒯 = (; zip(names, columns)...)
  newtable = 𝒯 |> Tables.materializer(table)
  newtable, cache
end

function revert(::Levels, newtable, cache)
  cols = Tables.columns(newtable)
  names = Tables.columnnames(cols)

  columns = map(names, cache) do nm, revfunc
    x = Tables.getcolumn(cols, nm)
    revfunc(x)
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newtable)
end

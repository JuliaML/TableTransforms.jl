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
struct Levels{S<:ColSpec,O<:ColSpec,L} <: Stateless
  colspec::S
  ordered::O
  levels::L
end

Levels(pairs::Pair{T}...; ordered=nothing) where {T<:ColSelector} =
  Levels(ColSpec(first.(pairs)), ColSpec(ordered), last.(pairs))

Levels(; kwargs...) = throw(ArgumentError("Cannot create a Levels object without arguments."))

isrevertible(transform::Levels) = true

function apply(transform::Levels, table)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  snames = choose(transform.colspec, names)
  ordered = choose(transform.ordered, snames)
  tlevels = transform.levels
  
  results = map(names) do nm
    x = Tables.getcolumn(cols, nm)
    
    if nm ∈ snames
      assert_categorical(x)
      
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

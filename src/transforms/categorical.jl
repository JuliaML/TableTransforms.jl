# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Categorical(col₁, col₂, ..., colₙ; ordered=nothing)
    Categorical([col₁, col₂, ..., colₙ]; ordered=nothing)
    Categorical((col₁, col₂, ..., colₙ); ordered=nothing)

Make selected columns col₁, col₂, ..., colₙ categorical using `categorical` function from CategoricalArrays.jl.
`ordered` keyword argument can be a tuple, vector or regex that selects the columns where `ordered=true`.

    Categorical(regex; ordered=nothing)

Make columns that match with `regex` categorical.

    Categorical(col₁ => levels₁, ..., colₙ => levels₂; ordered=nothing)

Make selected columns col₁, col₂, ..., colₙ categorical by specifying the levels of each one.

# Examples

```julia
Categorical(1, 3, 5)
Categorical([:a, :c, :e], ordered=[:c])
Categorical(("a", "c", "e"), ordered=("a", "e"))
Categorical(r"[ace]", ordered=[1, 2])

# with levels
Categorical(1 => 1:3, 2 => ["a", "b"])
Categorical(:a => 1:3, :b => ["a", "b"], ordered=[:a])
Categorical("a" => 1:3, "b" => ["a", "b"], ordered=["b"])
```
"""
struct Categorical{S<:ColSpec,O<:ColSpec,L} <: Stateless
  colspec::S
  ordered::O
  levels::L
end

Categorical(colspec::ColSpec; ordered::ColSpec=nothing) =
  Categorical(colspec, ordered, nothing)

Categorical(cols::T...; ordered::ColSpec=nothing) where {T<:ColSelector} =
  Categorical(values(cols), ordered, nothing)

Categorical(pairs::Pair{T}...; ordered::ColSpec=nothing) where {T<:ColSelector} =
  Categorical(first.(pairs), ordered, last.(pairs))

# argument errors
Categorical(::Tuple{}; ordered) = throw(ArgumentError("Cannot create a Categorical object with empty tuple."))
Categorical(; ordered) = throw(ArgumentError("Cannot create a Categorical object without arguments."))

_levels(::Nothing, nm, snames) = nothing
_levels(levels::Tuple, nm, snames) = levels[findfirst(==(nm), snames)]

function apply(transform::Categorical, table)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  snames = choose(transform.colspec, names)
  ordered = choose(transform.ordered, snames)
  levels = transform.levels
  
  columns = map(names) do nm
    x = Tables.getcolumn(cols, nm)
    if nm ∈ snames
      o = nm ∈ ordered
      l = _levels(levels, nm, snames)
      return categorical(x, ordered=o, levels=l)
    end
    x
  end

  𝒯 = (; zip(names, columns)...)
  newtable = 𝒯 |> Tables.materializer(table)
  newtable, snames
end

function revert(::Categorical, newtable, cache)
  cols = Tables.columns(newtable)
  names = Tables.columnnames(cols)

  columns = map(names) do nm
    x = Tables.getcolumn(cols, nm)
    nm ∈ cache ? unwrap.(x) : x
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newtable)
end

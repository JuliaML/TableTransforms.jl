# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Categorize(col₁, col₂, ..., colₙ; ordered=nothing)
    Categorize([col₁, col₂, ..., colₙ]; ordered=nothing)
    Categorize((col₁, col₂, ..., colₙ); ordered=nothing)

Make selected columns col₁, col₂, ..., colₙ categorical using `categorical` function from CategoricalArrays.jl.
`ordered` keyword argument can be a tuple, vector or regex that selects the columns where `ordered=true`.

    Categorize(regex; ordered=nothing)

Make columns that match with `regex` categorical.

    Categorize(col₁ => levels₁, ..., colₙ => levels₂; ordered=nothing)

Make selected columns col₁, col₂, ..., colₙ categorical by specifying the levels of each one.

# Examples

```julia
Categorize(1, 3, 5)
Categorize([:a, :c, :e], ordered=[:c])
Categorize(("a", "c", "e"), ordered=("a", "e"))
Categorize(r"[ace]", ordered=[1, 2])

# with levels
Categorize(1 => 1:3, 2 => ["a", "b"], ordered=r"a")
Categorize(:a => 1:3, :b => ["a", "b"], ordered=[:a])
Categorize("a" => 1:3, "b" => ["a", "b"], ordered=["b"])
```
"""
struct Categorize{S<:ColSpec,O<:ColSpec,L} <: Stateless
  colspec::S
  ordered::O
  levels::L
end

Categorize(colspec::ColSpec; ordered::ColSpec=nothing) =
  Categorize(colspec, ordered, nothing)

Categorize(cols::T...; ordered::ColSpec=nothing) where {T<:ColSelector} =
  Categorize(values(cols), ordered, nothing)

Categorize(pairs::Pair{T}...; ordered::ColSpec=nothing) where {T<:ColSelector} =
  Categorize(first.(pairs), ordered, last.(pairs))

# argument errors
Categorize(::Tuple{}; kwargs...) = throw(ArgumentError("Cannot create a Categorize object with empty tuple."))
Categorize(; kwargs...) = throw(ArgumentError("Cannot create a Categorize object without arguments."))

_levels(::Nothing, nm, snames) = nothing
_levels(levels::Tuple, nm, snames) = levels[findfirst(==(nm), snames)]

_categorical(x::AbstractVector, o, l) =
  categorical(x, ordered=o, levels=l), y -> unwrap.(y)

function _categorical(x::CategoricalArray, o, l)
  xo, xl = isordered(x), levels(x)
  revfunc = y -> categorical(y, ordered=xo, levels=xl)
  categorical(x, ordered=o, levels=l), revfunc
end

function apply(transform::Categorize, table)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  snames = choose(transform.colspec, names)
  ordered = choose(transform.ordered, snames)
  levels = transform.levels
  
  results = map(names) do nm
    x = Tables.getcolumn(cols, nm)
    if nm ∈ snames
      o = nm ∈ ordered
      l = _levels(levels, nm, snames)
      return _categorical(x, o, l)
    end
    x, identity
  end

  columns, cache = first.(results), last.(results)

  𝒯 = (; zip(names, columns)...)
  newtable = 𝒯 |> Tables.materializer(table)
  newtable, cache
end

function revert(::Categorize, newtable, cache)
  cols = Tables.columns(newtable)
  names = Tables.columnnames(cols)

  columns = map(names, cache) do nm, revfunc
    x = Tables.getcolumn(cols, nm)
    revfunc(x)
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newtable)
end

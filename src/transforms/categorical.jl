# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

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

_levels(::Nothing, snames) = Dict(snames .=> nothing)
_levels(levels::Vector, snames) = Dict(snames .=> levels)

function _ordered(colspec, snames)
  ordered = choose(colspec, snames)
  Dict(nm => nm ∈ ordered for nm in snames)
end

function apply(transform::Categorical, table)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  snames = choose(transform.colspec, names)
  levels = _levels(transform.levels, snames)
  ordered = _ordered(transform.ordered, snames)
  
  columns = map(names) do nm
    x = Tables.getcolumn(cols, nm)
    l = get(levels, nm, nothing)
    o = get(ordered, nm, false)
    nm ∈ snames ? categorical(x, levels=l, ordered=o) : x
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

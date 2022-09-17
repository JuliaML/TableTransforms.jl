# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Sort(col₁, col₂, ..., colₙ; kwargs...)
    Sort([col₁, col₂, ..., colₙ]; kwargs...)
    Sort((col₁, col₂, ..., colₙ); kwargs...)

Sort the rows of selected columns `col₁`, `col₂`, ..., `colₙ` by forwarding
the `kwargs` to the `sortperm` function.

    Sort(regex; kwargs...)

Sort the rows of columns that match with `regex`.

# Examples

```julia
Sort(:a)
Sort(:a, :c, rev=true)
Sort([1, 3, 5], by=row -> abs.(row))
Sort(("a", "c", "e"))
Sort(r"[ace]")
```
"""
struct Sort{S<:ColSpec,T} <: Stateless
  colspec::S
  kwargs::T
end

Sort(spec; kwargs...) = Sort(colspec(spec), values(kwargs))

Sort(cols::T...; kwargs...) where {T<:Col} = 
  Sort(colspec(cols), values(kwargs))

Sort(; kwargs...) = throw(ArgumentError("Cannot create a Sort object without arguments."))

isrevertible(::Type{<:Sort}) = true

isindexable(::Type{<:Sort}) = true

function indices(transform::Sort, table)
  cols   = Tables.columns(table)
  names  = Tables.columnnames(cols)
  snames = choose(transform.colspec, names)
  
  # use selected columns to calculate new order
  scols = Tables.getcolumn.(Ref(cols), snames)
  stups = collect(zip(scols...))
  sinds = sortperm(stups; transform.kwargs...)

  sinds, nothing
end

function apply(transform::Sort, table)
  # collect all rows
  rows = Tables.rowtable(table)

  # sorting indices
  sinds, _ = indices(transform, table)

  # sorted rows
  srows = view(rows, sinds)

  newtable = srows |> Tables.materializer(table)

  newtable, sinds
end

function revert(::Sort, newtable, cache)
  # collect all rows
  rows = Tables.rowtable(newtable)

  # reverting indices
  sinds = cache
  rinds = sortperm(sinds)

  rrows = view(rows, rinds)

  rrows |> Tables.materializer(newtable)
end

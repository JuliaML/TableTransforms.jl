# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Select(col₁, col₂, ..., colₙ)
    Select([col₁, col₂, ..., colₙ])
    Select((col₁, col₂, ..., colₙ))
    
The transform that selects columns `col₁`, `col₂`, ..., `colₙ`.

    Select(col₁ => newcol₁, col₂ => newcol₂, ..., colₙ => newcolₙ)

Selects the columns `col₁`, `col₂`, ..., `colₙ`
and rename them to `newcol₁`, `newcol₂`, ..., `newcolₙ`.
    
    Select(regex)

Selects the columns that match with `regex`.

# Examples

```julia
Select(1, 3, 5)
Select([:a, :c, :e])
Select(("a", "c", "e"))
Select(1 => :x, 3 => :y)
Select(:a => :x, :b => :y)
Select("a" => "x", "b" => "y")
Select(r"[ace]")
```
"""
struct Select{S<:ColumnSelector} <: StatelessFeatureTransform
  selector::S
  newnames::Union{Vector{Symbol},Nothing}
end

Select(spec) = Select(selector(spec), nothing)
Select(cols::C...) where {C<:Column} = Select(cols)

Select(pairs::Pair{C,Symbol}...) where {C<:Column} = Select(selector(first.(pairs)), collect(last.(pairs)))

Select(pairs::Pair{C,S}...) where {C<:Column,S<:AbstractString} =
  Select(selector(first.(pairs)), collect(Symbol.(last.(pairs))))

Select() = throw(ArgumentError("cannot create Select transform without arguments"))

function applyfeat(transform::Select, feat, prep)
  cols = Tables.columns(feat)
  names = collect(Tables.columnnames(cols))

  # lazy selection of columns
  snames = transform.selector(names)
  stable = TableSelection(feat, snames)

  # rename if necessary
  nnames = transform.newnames
  rename = isnothing(nnames) ? Identity() : Rename(nnames)
  newfeat = stable |> rename

  newfeat, nothing
end

"""
    Reject(col₁, col₂, ..., colₙ)
    Reject([col₁, col₂, ..., colₙ])
    Reject((col₁, col₂, ..., colₙ))

The transform that discards columns `col₁`, `col₂`, ..., `colₙ`.

    Reject(regex)

Discards the columns that match with `regex`.

# Examples

```julia
Reject(:b, :d, :f)
Reject(["b", "d", "f"])
Reject((2, 4, 6))
Reject(r"[bdf]")
```
"""
struct Reject{S<:ColumnSelector} <: StatelessFeatureTransform
  selector::S
end

Reject(cols) = Reject(selector(cols))
Reject(cols::C...) where {C<:Column} = Reject(selector(cols))

# argument errors
Reject() = throw(ArgumentError("cannot create Reject transform without arguments"))
Reject(::AllSelector) = throw(ArgumentError("cannot reject all columns"))

function applyfeat(transform::Reject, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = transform.selector(names)
  select = Select(setdiff(names, snames))
  newfeat, _ = applyfeat(select, feat, prep)
  newfeat, nothing
end

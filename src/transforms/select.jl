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

isrevertible(::Type{<:Select}) = true

# utils
_newnames(::Nothing, select) = select
_newnames(names::Vector{Symbol}, select) = names

function applyfeat(transform::Select, feat, prep)
  cols = Tables.columns(feat)
  names = collect(Tables.columnnames(cols))

  # retrieve relevant column names
  select = transform.selector(names)
  reject = setdiff(names, select)
  newnames = _newnames(transform.newnames, select)

  # keep track of indices to revert later
  sinds = indexin(select, names)
  rinds = indexin(reject, names)

  # sort indices to facilitate reinsertion
  sperm = sortperm(sinds)

  # rejected columns
  rcolumns = [Tables.getcolumn(cols, name) for name in reject]

  fcache = (select, sperm, reject, rcolumns, rinds)
  newfeat = TableSelection(feat, newnames, select)
  newfeat, fcache
end

function revertfeat(::Select, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)
  # https://github.com/JuliaML/TableTransforms.jl/issues/76
  columns = Any[Tables.getcolumn(cols, name) for name in names]

  select, sperm, reject, rcolumns, rinds = fcache

  # restore rejected columns
  onames = select[sperm]
  ocolumns = columns[sperm]
  for (i, rind) in enumerate(rinds)
    insert!(onames, rind, reject[i])
    insert!(ocolumns, rind, rcolumns[i])
  end

  𝒯 = (; zip(onames, ocolumns)...)
  𝒯 |> Tables.materializer(newfeat)
end

# reverting a single TableSelection is trivial
revertfeat(::Select, newfeat::TableSelection, fcache) = newfeat.table

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

isrevertible(::Type{<:Reject}) = true

function applyfeat(transform::Reject, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  reject = transform.selector(names)
  select = setdiff(names, reject)
  strans = Select(select)
  newfeat, sfcache = applyfeat(strans, feat, prep)
  newfeat, (strans, sfcache)
end

function revertfeat(::Reject, newfeat, fcache)
  strans, sfcache = fcache
  revertfeat(strans, newfeat, sfcache)
end

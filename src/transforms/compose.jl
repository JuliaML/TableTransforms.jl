# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Compose(; as=:CODA)

Converts all columns of the table into parts of a composition
in a new column named `as`, using the `CoDa.compose` function.

    Compose(col₁, col₂, ..., colₙ; as=:CODA)
    Compose([col₁, col₂, ..., colₙ]; as=:CODA)
    Compose((col₁, col₂, ..., colₙ); as=:CODA)

Converts the selected columns `col₁`, `col₂`, ..., `colₙ` into parts of a composition.

    Compose(regex; as=:CODA)

Converts the columns that match with `regex` into parts of a composition.

# Examples

```julia
Compose(as=:comp)
Compose([2, 3, 5])
Compose([:b, :c, :e])
Compose(("b", "c", "e"))
Compose(r"[bce]", as="COMP")
```
"""
struct Compose{S<:ColumnSelector} <: StatelessFeatureTransform
  selector::S
  as::Symbol
end

Compose(selector::ColumnSelector; as=:CODA) = Compose(selector, Symbol(as))

Compose(; kwargs...) = Compose(AllSelector(); kwargs...)
Compose(cols; kwargs...) = Compose(selector(cols); kwargs...)
Compose(cols::C...; kwargs...) where {C<:Column} = Compose(selector(cols); kwargs...)

isrevertible(::Type{<:Compose}) = true

function applyfeat(transform::Compose, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = transform.selector(names)
  as = transform.as

  newfeat = compose(feat, snames; as)

  newfeat, (names, snames, as)
end

function revertfeat(::Compose, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names, snames, as = fcache

  coda = Tables.getcolumn(cols, as)
  columns = map(names) do name
    if name ∈ snames
      Tables.getcolumn(coda, name)
    else
      Tables.getcolumn(cols, name)
    end
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

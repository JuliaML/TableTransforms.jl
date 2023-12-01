# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SciTypeAssertion(; scitype=S)

Asserts that all columns of the table have scientific type `S`.

    SciTypeAssertion(col₁, col₂, ..., colₙ; scitype=S)
    SciTypeAssertion([col₁, col₂, ..., colₙ]; scitype=S)
    SciTypeAssertion((col₁, col₂, ..., colₙ); scitype=S)

Asserts that the selected columns `col₁`, `col₂`, ..., `colₙ` have scientific type `S`.

    SciTypeAssertion(regex; scitype=S)

Asserts that the columns that match with `regex` have scientific type `S`.

# Examples

```julia
import DataScienceTraits as DST
SciTypeAssertion(scitype=DST.Continuous)
SciTypeAssertion([2, 3, 5], scitype=DST.Categorical)
SciTypeAssertion([:b, :c, :e], scitype=DST.Continuous)
SciTypeAssertion(("b", "c", "e"), scitype=DST.Categorical)
SciTypeAssertion(r"[bce]", scitype=DST.Continuous)
```
"""
struct SciTypeAssertion{S<:ColumnSelector} <: StatelessFeatureTransform
  selector::S
  scitype::DataType
end

SciTypeAssertion(selector::ColumnSelector; scitype::Type{<:SciType}) = SciTypeAssertion(selector, scitype)

SciTypeAssertion(; kwargs...) = SciTypeAssertion(AllSelector(); kwargs...)
SciTypeAssertion(cols; kwargs...) = SciTypeAssertion(selector(cols); kwargs...)
SciTypeAssertion(cols::C...; kwargs...) where {C<:Column} = SciTypeAssertion(selector(cols); kwargs...)

isrevertible(::Type{<:SciTypeAssertion}) = true

function applyfeat(transform::SciTypeAssertion, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = transform.selector(names)
  S = transform.scitype

  for nm in snames
    x = Tables.getcolumn(cols, nm)
    _assert(elscitype(x) <: S, "the elements of the column '$nm' are not of scientific type $S")
  end

  feat, nothing
end

revertfeat(::SciTypeAssertion, newfeat, fcache) = newfeat

# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Assert(; cond, msg="")

Asserts all columns of the table by throwing a `AssertionError(msg)`
if `cond(column)` returns `false`, otherwise returns the input table.

The `msg` argument can be a string, or a function that receives
the column name and returns a string, e.g.: `nm -> "error in column \$nm"`.

    Assert(col₁, col₂, ..., colₙ; cond, msg="")
    Assert([col₁, col₂, ..., colₙ]; cond, msg="")
    Assert((col₁, col₂, ..., colₙ); cond, msg="")

Asserts the selected columns `col₁`, `col₂`, ..., `colₙ`.

    Assert(regex; cond, msg="")

Asserts the columns that match with `regex`.

# Examples

```julia
Assert(cond=allunique, msg="assertion error")
Assert([2, 3, 5], cond=x -> sum(x) > 100)
Assert([:b, :c, :e], cond=x -> eltype(x) <: Integer)
Assert(("b", "c", "e"), cond=allunique, msg=nm -> "error in column \$nm")
Assert(r"[bce]", cond=x -> sum(x) > 100)
```
"""
struct Assert{S<:ColumnSelector,C,M} <: StatelessFeatureTransform
  selector::S
  cond::C
  msg::M
end

Assert(selector::ColumnSelector; cond, msg="") = Assert(selector, cond, msg)

Assert(; kwargs...) = Assert(AllSelector(); kwargs...)
Assert(cols; kwargs...) = Assert(selector(cols); kwargs...)
Assert(cols::C...; kwargs...) where {C<:Column} = Assert(selector(cols); kwargs...)

isrevertible(::Type{<:Assert}) = true

function applyfeat(transform::Assert, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = transform.selector(names)
  cond = transform.cond
  msg = transform.msg

  msgfun = msg isa AbstractString ? _ -> msg : msg
  for nm in snames
    x = Tables.getcolumn(cols, nm)
    _assert(cond(x), msgfun(nm))
  end

  feat, nothing
end

revertfeat(::Assert, newfeat, fcache) = newfeat

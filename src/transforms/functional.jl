# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Functional(fun)

The transform that applies a `fun` elementwise.

    Functional(col₁ => fun₁, col₂ => fun₂, ..., colₙ => funₙ)

Apply the corresponding `funᵢ` function to each `colᵢ` column.

# Examples

```julia
Functional(cos)
Functional(sin)
Functional(1 => cos, 2 => sin)
Functional(:a => cos, :b => sin)
Functional("a" => cos, "b" => sin)
```
"""
struct Functional{S<:ColumnSelector,F} <: StatelessFeatureTransform
  selector::S
  fun::F
end

Functional(fun) = Functional(AllSelector(), fun)

Functional(pairs::Pair{C}...) where {C<:Column} = Functional(selector(first.(pairs)), last.(pairs))

Functional() = throw(ArgumentError("cannot create Functional transform without arguments"))

isrevertible(transform::Functional) = isinvertible(transform)

_hasinverse(f) = !(invfun(f) isa NoInverse)

isinvertible(transform::Functional{AllSelector}) = _hasinverse(transform.fun)
isinvertible(transform::Functional) = all(_hasinverse, transform.fun)

inverse(transform::Functional{AllSelector}) = Functional(transform.selector, invfun(transform.fun))
inverse(transform::Functional) = Functional(transform.selector, invfun.(transform.fun))

_fundict(fun, names) = Dict(nm => fun for nm in names)
_fundict(funs::Tuple, names) = Dict(names .=> funs)

function applyfeat(transform::Functional, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = transform.selector(names)
  fundict = _fundict(transform.fun, snames)

  columns = map(names) do name
    x = Tables.getcolumn(cols, name)
    if name ∈ snames
      fun = fundict[name]
      y = map(fun, x)
    else
      y = x
    end
    y
  end

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)

  newfeat, nothing
end

function revertfeat(transform::Functional, newfeat, fcache)
  ofeat, _ = applyfeat(inverse(transform), newfeat, nothing)
  ofeat
end

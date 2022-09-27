# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Functional(func)

The transform that applies a `func` elementwise.

    Functional(col₁ => func₁, col₂ => func₂, ..., colₙ => funcₙ)

Apply the corresponding `funcᵢ` function to each `colᵢ` column.

# Examples

```julia
Functional(cos)
Functional(sin)
Functional(1 => cos, 2 => sin)
Functional(:a => cos, :b => sin)
Functional("a" => cos, "b" => sin)
```
"""
struct Functional{S<:ColSpec,F} <: StatelessTableTransform
  colspec::S
  func::F
end

Functional(func) = Functional(AllSpec(), func)

Functional(pairs::Pair{T}...) where {T<:Col} =
  Functional(colspec(first.(pairs)), last.(pairs))

Functional() = throw(ArgumentError("Cannot create a Functional object without arguments."))

# known invertible functions
inverse(::typeof(log))  = exp
inverse(::typeof(exp))  = log
inverse(::typeof(cos))  = acos
inverse(::typeof(acos)) = cos
inverse(::typeof(sin))  = asin
inverse(::typeof(asin)) = sin
inverse(::typeof(cosd))  = acosd
inverse(::typeof(acosd)) = cosd
inverse(::typeof(sind))  = asind
inverse(::typeof(asind)) = sind
inverse(::typeof(identity)) = identity

# fallback to nothing
inverse(::Any) = nothing

isrevertible(transform::Functional{AllSpec}) =
  !isnothing(inverse(transform.func))

isrevertible(transform::Functional) =
  all(!isnothing, inverse.(transform.func))

_funcdict(func, names) = Dict(nm => func for nm in names)
_funcdict(func::Tuple, names) = Dict(names .=> func)

function applyfeat(transform::Functional, feat, prep) 
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = choose(transform.colspec, names)
  funcs = _funcdict(transform.func, snames)
  
  columns = map(names) do nm
    x = Tables.getcolumn(cols, nm)
    if nm ∈ snames
      func = funcs[nm]
      y = func.(x)
    else
      y = x
    end
    y
  end

  𝒯 = (; zip(names, columns)...)
  newfeat = 𝒯 |> Tables.materializer(feat)
  return newfeat, (snames, funcs)
end

function revertfeat(transform::Functional, newfeat, fcache)
  @assert isrevertible(transform) "TableTransform is not revertible."

  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)
  
  snames, funcs = fcache

  columns = map(names) do nm
    y = Tables.getcolumn(cols, nm)
    if nm ∈ snames
      func = funcs[nm]
      invfunc = inverse(func)
      x = invfunc.(y)
    else
      x = y
    end
    x
  end

  𝒯 = (; zip(names, columns)...)
  𝒯 |> Tables.materializer(newfeat)
end

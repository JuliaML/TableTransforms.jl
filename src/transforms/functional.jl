# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Functional(func)

The transform that applies a `func` elementwise.

    Functional(col₁ => func₁, col₂ => func₂, ..., colₙ => funcₙ)

Applies in each `colᵢ` the function `funcᵢ` in the table.

# Examples

```julia
Functional(cos)
Functional(sin)
Functional(:a => cos, :b => sin)
Functional("a" => cos, "b" => sin)
```
"""
struct Functional{K,F} <: Stateless
  pairs::Dict{K,F}
end

Functional(func) = Functional(Dict((:) => func))

Functional(pairs::Pair{Symbol,F}...) where {F} =
  Functional(Dict(pairs))

Functional(pairs::Pair{K,F}...) where {K<:AbstractString,F} =
  Functional(Dict(Symbol(k) => v for (k, v) in pairs))

Functional() = throw(ArgumentError("Cannot create a Functional object without arguments."))

# known invertible functions
inverse(::typeof(log))   = exp
inverse(::typeof(exp))   = log
inverse(::typeof(cos))   = acos
inverse(::typeof(acos))  = cos
inverse(::typeof(sin))   = asin
inverse(::typeof(asin))  = sin
inverse(::typeof(cosd))  = acosd
inverse(::typeof(acosd)) = cosd
inverse(::typeof(sind))  = asind
inverse(::typeof(asind)) = sind

# fallback to nothing
inverse(::Any) = nothing

isrevertible(transform::Functional{Colon}) =
  !isnothing(inverse(transform.pairs[:]))

isrevertible(transform::Functional) =
  any(isnothing, inverse.(values(transform.pairs)))

function applyfunc(transform::Functional, cols, nm)
  x = Tables.getcolumn(cols, nm)
  func = get(transform.pairs, nm, identity)
  func.(x)
end

function applyfunc(transform::Functional{Colon}, cols, nm)
  x = Tables.getcolumn(cols, nm)
  func = transform.pairs[:]
  func.(x)
end

function apply(transform::Functional, table) 
  cols = Tables.getcolumns(table)
  names = Tables.columnnames(table)
  ncols = tcollect(applyfunc(transform, cols, nm) for nm in names)
  𝒯 = (; zip(names, ncols)...)
  newtable = 𝒯 |> Tables.materializer(table)
  return newtable, nothing
end

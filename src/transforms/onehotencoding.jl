# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    OneHotEncoding(col₁, col₂, ..., colₙ)
    OneHotEncoding([col₁, col₂, ..., colₙ])
    OneHotEncoding((col₁, col₂, ..., colₙ))
    
The transform that selects columns `col₁`, `col₂`, ..., `colₙ`.
    
    OneHotEncoding(regex)

Selects the columns that match with `regex`.

# Examples

```julia
OneHotEncoding(1, 3, 5)
OneHotEncoding([:a, :c, :e])
OneHotEncoding(("a", "c", "e"))
OneHotEncoding(r"[ace]")
```
"""
struct OneHotEncoding{S<:ColSpec} <: Stateless
    colspec::S
end

OneHotEncoding(cols::T...) where {T<:ColSelector} = 
  OneHotEncoding(cols)

# argument errors
OneHotEncoding(::Tuple{}) = throw(ArgumentError("Cannot create a OneHotEncoding object with empty tuple."))
OneHotEncoding() = throw(ArgumentError("Cannot create a OneHotEncoding object without arguments."))

_levels(x) = levels(categorical(x))
_levels(x::CategoricalArray) = levels(x)

function apply(transform::OneHotEncoding, table)
    cols = Tables.columns(table)
    names = Tables.columnnames(cols)
    snames = choose(transform.colspec, names)

    columns = [nm => Tables.getcolumn(cols, nm) for nm in names]
    results = map(snames) do nm
        x = Tables.getcolumn(cols, nm)
        levels = _levels(x)
        map(levels) do l
            Symbol(nm, "_", l) => x[x .== l]
        end
    end
    onehotcols = collect(Iterators.flatten(results))

    𝒯 = NamedTuple([columns; onehotcols])
    newtable = 𝒯 |> Tables.materializer(table)
    newtable, names
end

function revert(::OneHotEncoding, newtable, cache)
    cols = Tables.columns(table)
    columns = [Tables.getcolumn(cols, nm) for nm in cache]
    𝒯 = (; zip(cache, columns)...)
    𝒯 |> Tables.materializer(newtable)
end

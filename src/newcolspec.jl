# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# types used to select a column
const Col = Union{Symbol,Integer,AbstractString}

"""
    ColSpec  

`ColSpec` is the parent type of all spec types used to select columns.
The `ColSpec` abstract type together with the `Col` union type 
and the `choose` function form the ColSpec interface.

To implement the ColSpec interface, the following steps must be performed:

1 - Add colspec field:

```julia
struct MyTransform{S<:ColSpec,#= other type params =#}
  colspec::S
  # other fileds
end
```

2 - Convert spec to ColSpec using the `ColSpec` type constructor:

```julia
MyTransform(spec, #= other arguments =#) = 
  MyTransform(ColSpec(spec), #= other arguments =#)
```

3 - Use `choose(colspec, names)` function in apply:

```julia
function apply(transform::MyTransform, table)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  # selected column names
  snames = choose(transform.colspec, names)
  # code...
end
```

If you need to create constructors that accept 
individual column selectors use the `Col` type. Example:

```julia
function MyTransform(args::T...) where {T<:Col}
  MyTransform(ColSpec(args))
end
```
"""
abstract type ColSpec end

struct NameSpec <: ColSpec
  names::Vector{Symbol}
  function NameSpec(names)
    @assert !isempty(names) "Invalid column selection."
    new(names)
  end
end

struct IndexSpec <: ColSpec
  inds::Vector{Int}
  function IndexSpec(inds)
    @assert !isempty(inds) "Invalid column selection."
    new(inds)
  end
end

struct RegexSpec <: ColSpec
  regex::Regex
end

struct AllSpec <: ColSpec end

struct NoneSpec <: ColSpec end

"""
    ColSpec(spec)

The `ColSpec` type constructor returns a ColSpec object 
corresponding to the `spec` argument.

# Examples

```julia
ColSpec([:a, :b, :c]) # NameSpec
ColSpec((:a, :b, :c)) # NameSpec
ColSpec(["a", "b", "c"]) # NameSpec
ColSpec(("a", "b", "c")) # NameSpec
ColSpec(1:10) # IndexSpec
ColSpec((1, 2, 3)) # IndexSpec
ColSpec(r"[abc]") # RegexSpec
ColSpec(:) # AllSpec
ColSpec(nothing) # NoneSpec
# if the argument is a ColSpec, return it
ColSpec(NoneSpec()) # NoneSpec
```
"""
ColSpec(colspec::ColSpec) = colspec

ColSpec(names::AbstractVector{Symbol}) = NameSpec(names)
ColSpec(names::AbstractVector{<:AbstractString}) = NameSpec(Symbol.(names))
ColSpec(names::NTuple{N,Symbol}) where {N} = NameSpec(collect(names))
ColSpec(names::NTuple{N,<:AbstractString}) where {N} = NameSpec(collect(Symbol.(names)))

ColSpec(inds::AbstractVector{<:Integer}) = IndexSpec(inds)
ColSpec(inds::NTuple{N,<:Integer}) where {N} = IndexSpec(collect(inds))

ColSpec(regex::Regex) = RegexSpec(regex)

ColSpec(::Colon) = AllSpec()

ColSpec(::Nothing) = NoneSpec()

# ArgumentError
ColSpec(::Tuple{}) = throw(ArgumentError("Invalid column spec."))
ColSpec(::Any) = throw(ArgumentError("Invalid column spec."))

"""
    choose(colspec::ColSpec, names) -> Vector{Symbol}

Choose column `names` using `colspec`.

# Examples

```julia
julia> names = (:a, :b, :c, :d, :e, :f);

julia> choose(ColSpec(["a", "c", "e"]), names)
3-element Vector{Symbol}:
 :a
 :c
 :e

julia> choose(ColSpec((1, 3, 5)), names)
3-element Vector{Symbol}:
 :a
 :c
 :e

julia> choose(RegexSpec(r"[ace]"), names)
3-element Vector{Symbol}:
 :a
 :c
 :e

julia> choose(AllSpec(), names)
6-element Vector{Symbol}:
  :a
  :b
  :c
  :d
  :e
  :f

julia> choose(NoneSpec(), names)
Symbol[]
```
"""
choose(colspec::NameSpec, names) = _choose(colspec.names, names)

choose(colspec::IndexSpec, names::Tuple) = choose(colspec, collect(names))
choose(colspec::IndexSpec, names::Vector) = names[colspec.inds]

choose(colspec::RegexSpec, names::Tuple) = choose(colspec, collect(names))
function choose(colspec::RegexSpec, names::Vector)
  regex = colspec.regex
  snames = filter(nm -> occursin(regex, String(nm)), names)
  @assert !isempty(snames) "Invalid column selection."
  _choose(snames, names)
end

choose(::AllSpec, names::Tuple) = collect(names)
choose(::AllSpec, names::Vector) = names

choose(::NoneSpec, names) = Symbol[]

function _choose(snames::Vector{Symbol}, names)
  # validate columns
  @assert snames ⊆ names "Invalid column selection."
  return snames
end

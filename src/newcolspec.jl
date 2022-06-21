# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Col

Union of types used to select a column.
"""
const Col = Union{Symbol,Integer,AbstractString}

"""
    ColSpec  

`ColSpec` is the parent type of all spec types used to select columns.
The `ColSpec` abstract type together with the `Col` union type, the `colspec` function
and the `choose` function form the ColSpec interface.

To implement the ColSpec interface, the following steps must be performed:

1 - Add colspec field:

```julia
struct MyTransform{S<:ColSpec,#= other type params =#}
  colspec::S
  # other fileds
end
```

2 - Convert spec to ColSpec using the `colspec` function:

```julia
MyTransform(spec, #= other arguments =#) = 
  MyTransform(colspec(spec), #= other arguments =#)
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
  MyTransform(colspec(args))
end
```
"""
abstract type ColSpec end

"""
    colspec(spec)

Converts the `spec` argument to a `ColSpec` object.

# Examples

```julia
colspec([:a, :b, :c]) # NameSpec
colspec((:a, :b, :c)) # NameSpec
colspec(["a", "b", "c"]) # NameSpec
colspec(("a", "b", "c")) # NameSpec
colspec(1:10) # IndexSpec
colspec((1, 2, 3)) # IndexSpec
colspec(r"[abc]") # RegexSpec
colspec(:) # AllSpec
colspec(nothing) # NoneSpec
# if the argument is a ColSpec, return it
colspec(NoneSpec()) # NoneSpec
```
"""
colspec(colspec::ColSpec) = colspec

# argument errors
colspec(::Tuple{}) = throw(ArgumentError("Invalid column spec."))
colspec(::Any) = throw(ArgumentError("Invalid column spec."))

"""
    choose(colspec::ColSpec, names) -> Vector{Symbol}

Choose column `names` using `colspec`.

# Examples

```julia
julia> names = (:a, :b, :c, :d, :e, :f);

julia> choose(colspec(["a", "c", "e"]), names)
3-element Vector{Symbol}:
 :a
 :c
 :e

julia> choose(colspec((1, 3, 5)), names)
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
function choose end

# NameSpec: select columns using names
struct NameSpec <: ColSpec
  names::Vector{Symbol}
  function NameSpec(names)
    @assert !isempty(names) "Invalid column selection."
    new(names)
  end
end

colspec(names::AbstractVector{Symbol}) = NameSpec(names)
colspec(names::AbstractVector{<:AbstractString}) = NameSpec(Symbol.(names))
colspec(names::NTuple{N,Symbol}) where {N} = NameSpec(collect(names))
colspec(names::NTuple{N,<:AbstractString}) where {N} = NameSpec(collect(Symbol.(names)))

choose(colspec::NameSpec, names) = _choose(colspec.names, names)

# IndexSpec: select columns using indices
struct IndexSpec <: ColSpec
  inds::Vector{Int}
  function IndexSpec(inds)
    @assert !isempty(inds) "Invalid column selection."
    new(inds)
  end
end

colspec(inds::AbstractVector{<:Integer}) = IndexSpec(inds)
colspec(inds::NTuple{N,<:Integer}) where {N} = IndexSpec(collect(inds))

choose(colspec::IndexSpec, names::Tuple) = choose(colspec, collect(names))
choose(colspec::IndexSpec, names::Vector) = names[colspec.inds]

# RegexSpec: select columns than match with regex
struct RegexSpec <: ColSpec
  regex::Regex
end

colspec(regex::Regex) = RegexSpec(regex)

choose(colspec::RegexSpec, names::Tuple) = choose(colspec, collect(names))
function choose(colspec::RegexSpec, names::Vector)
  regex = colspec.regex
  snames = filter(nm -> occursin(regex, String(nm)), names)
  @assert !isempty(snames) "Invalid column selection."
  _choose(snames, names)
end

# AllSpec: select all columns
struct AllSpec <: ColSpec end

colspec(::Colon) = AllSpec()

choose(::AllSpec, names::Tuple) = collect(names)
choose(::AllSpec, names::Vector) = names

# NoneSpec: select no column
struct NoneSpec <: ColSpec end

colspec(::Nothing) = NoneSpec()

choose(::NoneSpec, names) = Symbol[]

# helper functions
function _choose(snames::Vector{Symbol}, names)
  # validate columns
  @assert snames ⊆ names "Invalid column selection."
  return snames
end

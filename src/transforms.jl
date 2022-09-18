# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Transform

A transform that takes a table as input and produces a new table.
Any transform implementing the `Transform` trait should implement the
[`apply`](@ref) function. If the transform [`isrevertible`](@ref),
then it should also implement the [`revert`](@ref) function.

A functor interface is automatically generated from the functions
above, which means that any transform implementing the `Transform`
trait can be evaluated directly at any table implementing the
[Tables.jl](https://github.com/JuliaData/Tables.jl) interface.
"""
abstract type Transform end

"""
    assertions(transform)

Returns a list of assertion functions for the `transform`. An assertion
function is a function that takes a table as input and checks if the table
is valid for the `transform`.
"""
function assertions end

"""
    isrevertible(transform)

Tells whether or not the `transform` is revertible, i.e. supports a
[`revert`](@ref) function. Defaults to `false` for new types.
"""
function isrevertible end

"""
    prep = preprocess(transform, table)

Pre-process `table` with `transform` to produce a `preproc` object
that can be used by both [`applyfeat`](@ref) and [`applymeta`](@ref).
This function is intended for developers of new types.
"""
function preprocess end

"""
    newtable, cache = apply(transform, table)

Apply the `transform` on the `table`. Return the `newtable` and a
`cache` to revert the transform later. If the table transform is
a feature transform, the new type only needs to implement the
function [`applyfeat`](@ref).
"""
function apply end

"""
    newfeat, fcache = applyfeat(transform, feat, prep)

Implementation of [`apply`](@ref) without treatment of metadata.
This function is intended for developers of new types.
"""
function applyfeat end

"""
    newmeta, mcache = applymeta(transform, meta, prep)

Implementation of [`apply`](@ref) for metadata.
This function is intended for developers of new types.
"""
function applymeta end

"""
    table = revert(transform, newtable, cache)

Revert the `transform` on the `newtable` using the `cache` from the
corresponding [`apply`](@ref) call and return the original `table`.
Only defined when the `transform` [`isrevertible`](@ref). If the
table transform is a feature transform, the new type only needs to
implement the function [`revertfeat`](@ref).
"""
function revert end

"""
    feat = revertfeat(transform, newfeat, fcache)

Implementation of [`revert`](@ref) without treatment of metadata.
This function is intended for developers of new types.
"""
function revertfeat end

"""
    meta = revertmeta(transform, newmeta, mcache)

Implementation of [`revert`](@ref) for metadata.
This function is intended for developers of new types.
"""
function revertmeta end

"""
    Stateless

This trait is useful to signal that we can [`reapply`](@ref) a transform
"fitted" with training data to "test" data without relying on the `cache`.
"""
abstract type Stateless <: Transform end

"""
    newtable = reapply(transform, table, cache)

Reapply the `transform` to (a possibly different) `table` using a `cache`
that was created with a previous [`apply`](@ref) call. If the table transform
is a feature transform, the new type only needs to implement the function
[`reapplyfeat`](@ref).
"""
function reapply end

"""
    newfeat = reapplyfeat(transform, feat, fcache)

Implementation of [`reapply`](@ref) without treatment of metadata.
This function is intended for developers of new types.
"""
function reapplyfeat end

"""
    newmeta = reapplymeta(transform, meta, mcache)

Implementation of [`reapply`](@ref) for metadata.
This function is intended for developers of new types.
"""
function reapplymeta end

"""
    Colwise

A transform that is applied column-by-column. In this case, the new type
only needs to implement [`colapply`](@ref), [`colrevert`](@ref) and
[`colcache`](@ref). Efficient fallbacks are provided that execute these
functions in parallel for all columns with multiple threads.
"""
abstract type Colwise <: Transform end

"""
    y = colapply(transform, x, c)

Apply `transform` to column `x` with cache `c` and return new column `y`.
"""
function colapply end

"""
    x = colrevert(transform, y, c)

Revert `transform` starting from column `y` with cache `c` and return
original column `x`. Only defined when the `transform` [`isrevertible`](@ref).
"""
function colrevert end

"""
    c = colcache(transform, x)

Produce cache `c` necessary to [`colapply`](@ref) the `transform` on `x`.
If the `transform` [`isrevertible`](@ref) then the cache `c` can also be
used in [`colrevert`](@ref).
"""
function colcache end

# --------------------
# TRANSFORM FALLBACKS
# --------------------

assertions(transform::Transform) =
  assertions(typeof(transform))
assertions(::Type{<:Transform}) = []

isrevertible(transform::Transform) =
  isrevertible(typeof(transform))
isrevertible(::Type{<:Transform}) = false

preprocess(transform::Transform, table) = nothing

function apply(transform::Transform, table)
  feat, meta = divide(table)

  prep = preprocess(transform, table)

  newfeat, fcache = applyfeat(transform, feat, prep)
  newmeta, mcache = applymeta(transform, meta, prep)

  attach(newfeat, newmeta), (fcache, mcache)
end

function revert(transform::Transform, newtable, cache)
  newfeat, newmeta = divide(newtable)
  fcache,   mcache = cache

  feat = revertfeat(transform, newfeat, fcache)
  meta = revertmeta(transform, newmeta, mcache)

  attach(feat, meta)
end

function reapply(transform::Transform, table, cache)
  feat,     meta = divide(table)
  fcache, mcache = cache

  newfeat = reapplyfeat(transform, feat, fcache)
  newmeta = reapplymeta(transform, meta, mcache)

  attach(newfeat, newmeta)
end

applymeta(transform::Transform, meta, prep) = meta, nothing
revertmeta(transform::Transform, newmeta, mcache) = newmeta
reapplymeta(transform::Transform, meta, mcache) = meta

(transform::Transform)(table) =
  apply(transform, table) |> first

function Base.show(io::IO, transform::Transform)
  T = typeof(transform)
  vals = getfield.(Ref(transform), fieldnames(T))
  strs = repr.(vals, context=io)
  print(io, "$(nameof(T))($(join(strs, ", ")))")
end

function Base.show(io::IO, ::MIME"text/plain", transform::Transform)
  T = typeof(transform)
  fnames = fieldnames(T)
  len = length(fnames)
  print(io, "$(nameof(T)) transform")
  for (i, field) in enumerate(fnames)
    div = i == len ? "\n└─ " : "\n├─ "
    val = getfield(transform, field)
    str = repr(val, context=io)
    print(io, "$div$field = $str")
  end
end

# --------------------
# STATELESS FALLBACKS
# --------------------

reapply(transform::Stateless, table, cache) =
  apply(transform, table) |> first

# ------------------
# COLWISE FALLBACKS
# ------------------

function applyfeat(transform::Colwise, table, prep)
  # basic checks
  for assertion in assertions(transform)
    assertion(table)
  end

  # retrieve column names and values
  cols  = Tables.columns(table)
  names = Tables.columnnames(cols)

  # function to transform a single column
  function colfunc(n)
    x = Tables.getcolumn(cols, n)
    c = colcache(transform, x)
    y = colapply(transform, x, c)
    (n => y), c
  end

  # parallel map with multiple threads
  vals = tcollect(colfunc(n) for n in names)

  # new table with transformed columns
  𝒯 = (; first.(vals)...) |> Tables.materializer(table)

  # cache values for each column
  𝒞 = last.(vals)

  # return new table and cache
  𝒯, 𝒞
end

function revertfeat(transform::Colwise, newtable, cache)
  # basic checks
  @assert isrevertible(transform) "transform is not revertible"

  # transformed columns
  cols  = Tables.columns(newtable)
  names = Tables.columnnames(cols)
  
  # function to transform a single column
  function colfunc(i)
    n = names[i]
    c = cache[i]
    y = Tables.getcolumn(cols, n)
    x = colrevert(transform, y, c)
    n => x
  end

  # parallel map with multiple threads
  vals = tcollect(colfunc(i) for i in 1:length(names))

  # new table with transformed columns
  (; vals...) |> Tables.materializer(newtable)
end

function reapplyfeat(transform::Colwise, table, cache)
  # basic checks
  for assertion in assertions(transform)
    assertion(table)
  end

  # retrieve column names and values
  cols  = Tables.columns(table)
  names = Tables.columnnames(cols)
  
  # check that cache is valid
  @assert length(names) == length(cache) "invalid cache for table"

  # function to transform a single column
  function colfunc(i)
    n = names[i]
    c = cache[i]
    x = Tables.getcolumn(cols, n)
    y = colapply(transform, x, c)
    n => y
  end

  # parallel map with multiple threads
  vals = tcollect(colfunc(i) for i in 1:length(names))

  # new table with transformed columns
  (; vals...) |> Tables.materializer(table)
end

# ----------------
# IMPLEMENTATIONS
# ----------------

include("transforms/select.jl")
include("transforms/rename.jl")
include("transforms/stdnames.jl")
include("transforms/sort.jl")
include("transforms/sample.jl")
include("transforms/filter.jl")
include("transforms/replace.jl")
include("transforms/coalesce.jl")
include("transforms/coerce.jl")
include("transforms/levels.jl")
include("transforms/onehot.jl")
include("transforms/identity.jl")
include("transforms/center.jl")
include("transforms/scale.jl")
include("transforms/zscore.jl")
include("transforms/quantile.jl")
include("transforms/functional.jl")
include("transforms/eigenanalysis.jl")
include("transforms/rowtable.jl")
include("transforms/coltable.jl")
include("transforms/sequential.jl")
include("transforms/parallel.jl")

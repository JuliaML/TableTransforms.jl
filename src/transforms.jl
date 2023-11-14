# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    TableTransform

A transform that takes a table as input and produces a new table.
Any transform implementing the `TableTransform` trait should implement the
[`apply`](@ref) function. If the transform [`isrevertible`](@ref),
then it should also implement the [`revert`](@ref) function.

A functor interface is automatically generated from the functions
above, which means that any transform implementing the `TableTransform`
trait can be evaluated directly at any table implementing the
[Tables.jl](https://github.com/JuliaData/Tables.jl) interface.
"""
abstract type TableTransform <: Transform end

"""
    FeatureTransform

A transform that operates on the columns of the table containing
features, i.e., simple attributes such as numbers, strings, etc.
"""
abstract type FeatureTransform <: TableTransform end

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
    StatelessFeatureTransform

This trait is useful to signal that we can [`reapply`](@ref) a transform
"fitted" with training data to "test" data without relying on the `cache`.
"""
abstract type StatelessFeatureTransform <: FeatureTransform end

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
    ColwiseFeatureTransform

A feature transform that is applied column-by-column. In this case, the
new type only needs to implement [`colapply`](@ref), [`colrevert`](@ref)
and [`colcache`](@ref). Efficient fallbacks are provided that execute
these functions in parallel for all columns with multiple threads.

## Notes

* `ColwiseFeatureTransform` subtypes must have a `selector` field.
"""
abstract type ColwiseFeatureTransform <: FeatureTransform end

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

function apply(transform::FeatureTransform, table)
  feat, meta = divide(table)

  for assertion in assertions(transform)
    assertion(feat)
  end

  prep = preprocess(transform, feat)

  newfeat, fcache = applyfeat(transform, feat, prep)
  newmeta, mcache = applymeta(transform, meta, prep)

  attach(newfeat, newmeta), (fcache, mcache)
end

function revert(transform::FeatureTransform, newtable, cache)
  _assert(isrevertible(transform), "Transform is not revertible")

  newfeat, newmeta = divide(newtable)
  fcache, mcache = cache

  feat = revertfeat(transform, newfeat, fcache)
  meta = revertmeta(transform, newmeta, mcache)

  attach(feat, meta)
end

function reapply(transform::FeatureTransform, table, cache)
  feat, meta = divide(table)
  fcache, mcache = cache

  for assertion in assertions(transform)
    assertion(feat)
  end

  newfeat = reapplyfeat(transform, feat, fcache)
  newmeta = reapplymeta(transform, meta, mcache)

  attach(newfeat, newmeta)
end

applymeta(::FeatureTransform, meta, prep) = meta, nothing
revertmeta(::FeatureTransform, newmeta, mcache) = newmeta
reapplymeta(::FeatureTransform, meta, mcache) = meta

# --------------------
# STATELESS FALLBACKS
# --------------------

reapply(transform::StatelessFeatureTransform, table, cache) = apply(transform, table) |> first

# ------------------
# COLWISE FALLBACKS
# ------------------

function applyfeat(transform::ColwiseFeatureTransform, feat, prep)
  # retrieve column names and values
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  snames = transform.selector(names)

  # function to transform a single column
  function colfunc(n)
    x = Tables.getcolumn(cols, n)
    if n ∈ snames
      c = colcache(transform, x)
      y = colapply(transform, x, c)
    else
      c = nothing
      y = x
    end
    (n => y), c
  end

  # parallel map with multiple threads
  vals = tcollect(colfunc(n) for n in names)

  # new table with transformed columns
  𝒯 = (; first.(vals)...)
  newfeat = 𝒯 |> Tables.materializer(feat)

  # cache values for each column
  caches = last.(vals)

  # return new table and cache
  newfeat, (caches, snames)
end

function revertfeat(transform::ColwiseFeatureTransform, newfeat, fcache)
  # transformed columns
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)

  caches, snames = fcache

  # function to transform a single column
  function colfunc(i)
    n = names[i]
    c = caches[i]
    y = Tables.getcolumn(cols, n)
    x = n ∈ snames ? colrevert(transform, y, c) : y
    n => x
  end

  # parallel map with multiple threads
  vals = tcollect(colfunc(i) for i in 1:length(names))

  # new table with transformed columns
  (; vals...) |> Tables.materializer(newfeat)
end

function reapplyfeat(transform::ColwiseFeatureTransform, feat, fcache)
  # retrieve column names and values
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)

  caches, snames = fcache

  # check that cache is valid
  _assert(length(names) == length(caches), "invalid caches for feat")

  # function to transform a single column
  function colfunc(i)
    n = names[i]
    c = caches[i]
    x = Tables.getcolumn(cols, n)
    y = n ∈ snames ? colapply(transform, x, c) : x
    n => y
  end

  # parallel map with multiple threads
  vals = tcollect(colfunc(i) for i in 1:length(names))

  # new table with transformed columns
  (; vals...) |> Tables.materializer(feat)
end

# ----------------
# IMPLEMENTATIONS
# ----------------

include("transforms/select.jl")
include("transforms/only.jl")
include("transforms/rename.jl")
include("transforms/stdnames.jl")
include("transforms/sort.jl")
include("transforms/sample.jl")
include("transforms/filter.jl")
include("transforms/dropmissing.jl")
include("transforms/dropextrema.jl")
include("transforms/dropunits.jl")
include("transforms/absoluteunits.jl")
include("transforms/map.jl")
include("transforms/replace.jl")
include("transforms/coalesce.jl")
include("transforms/coerce.jl")
include("transforms/levels.jl")
include("transforms/indicator.jl")
include("transforms/onehot.jl")
include("transforms/center.jl")
include("transforms/scale.jl")
include("transforms/zscore.jl")
include("transforms/quantile.jl")
include("transforms/functional.jl")
include("transforms/eigenanalysis.jl")
include("transforms/projectionpursuit.jl")
include("transforms/closure.jl")
include("transforms/remainder.jl")
include("transforms/logratio.jl")
include("transforms/rowtable.jl")
include("transforms/coltable.jl")
include("transforms/parallel.jl")

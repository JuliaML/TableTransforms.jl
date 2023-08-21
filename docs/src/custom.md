# Custom Transforms
A short guide for extending the interface with your own custom transform.

## Motivation

TableTransforms currently supports over 25 different transforms that cover a wide variety of use cases ranging from ordinary table operations to complex statistical transformations and that all can be arbitrarily composed with one another through elegant syntax. It is easy to leverage all of those benefits as a developer of a new transforms that operates on tables so that it perfectly integrates with the rest of the TableTransforms ecosystem.

##  Custom Transform Basics
All the transforms in this package implement the transforms interface defined in the `TransformsBase` package so this is really the only dependency you need. The interface assumes the following about your implementation:

- Your transform operates on a single table 
- Your transform may be associated with some state that if computed while applying it for the first time and is then cached can help later reapply the transform on another table without recomputing the state
- Your transform may be revertible, meaning that a transformed table can be brought back to its original form, and it may need to use the cache for that
- Your transform may be invertible in the mathematical sense

!!! note "Revertible does not imply invertible"
    Reverting assumes that the transform has been applied already and reverts it. Meanwhile, invertible implies that there is a one-to-one mapping between the input and output tables so a table can be inverted to a corresponding input to the transform even if it was not transformed a priori.

## Creating a custom transform
In the following we shall demonstrate the steps to apply a custom transform. 

### 1. Declare a new type for your transform
The declaration struct should subtype `TransformsBase.Transforms` and it should have a named field for each input needed to apply the transform besides of the main table. For instance, if you want to call your transform `Standardize` and it takes two boolean inputs `center` and `scale`, then you should declare:

```julia
struct Standardizer <: TransformsBase.Transform
    center::Bool
    scale::Bool
end
```
You may implement keyword instructors as needed if some of the hyperparameters are optional. Thus, we follow up with:
```julia
Standardize(;center::Bool=true, scale::Bool=true) = Standardize(center, scale)
```

### 2. Implement the `apply` method for your transform
The `apply` method takes an object of your transform type and a table and returns a new table and cache. Suppose that the `Standardize` transform should zero-mean each column if `center` is true and scale each column to unit variance if `scale` is true, then the `apply` method should be implemented as follows:

```julia
using Statistics

function TransformsBase.apply(transform::Standardize, X)
    # convert the table to a matrix
    Xm = Tables.matrix(X)
    # compute the means and stds
    μ = transform.center ? mean(Xm, dims=1) : zeros(1, size(Xm, 2))
    σ = transform.scale ? std(Xm, dims=1) : ones(1, size(Xm, 2))
    # standardize the data
    Xm = (Xm .- μ) ./ σ
    # convert back to table
    Xm = X |> Tables.materializer(Xm)
    # return the table and cache that may help reapply or revert later
    return Xm, (μ, σ)
end
```

That's it really! Your transform now behaves like any table transform. For instance, we can do
```julia
using TableTransforms

X = (A=[1, 2, 3], B=[4, 5, 6])
Xt = X |> Standardize() |> Identity() |> Select([:A])
```

It holds, however, that in case your transform can be reapplied, is revertible, or is invertible then you should continue implementing the interface to support such functionality.

### 3. Optionally implement `reapply`
We need this in case of the `Standarize` transform because after computing the mean and std for some train table we may want to apply the transform directly given a test table. Hence, we implement `reapply` which has the same signature as apply but it takes an extra argument for the cache and doesn't return it.

```julia
function TransformsBase.reapply(transform::Standardize, X, cache)
    # convert the table to a matrix
    Xm = Tables.matrix(X)
    # no need to recompute means and stds
    μ, σ = cache
    # standardize the data
    Xm = (Xm .- μ) ./ σ
    # convert back to table
    Xm = X |> Tables.materializer(Xm)
    return Xm
end
```


### 4. Optionally specify that your transform is revertible and implement `revert`

We can specify reversibility for an arbitrary transform `T` by setting `isrevertible(::Type{T})` to `true`. It's obvious that this should be supported by our transform so we do

```julia
TransformsBase.isrevertible(::Type{Standardize}) = true
```
By default this falls back to false so users of the interface would be aware that revert is not implemented in that case.

Now we follow up by implementing the `revert` method which has the same signature as `reapply`.

```julia
function TransformsBase.revert(transform::Standardize, X, cache)
    # convert the table to a matrix
    Xm = Tables.matrix(X)
    # extract the mean and std
    μ, σ = cache
    # revert the transform
    Xm = Xm .* σ .+ μ
    # convert back to table
    Xm = X |> Tables.materializer(Xm)
    return Xm
end
```

### 5. Optionally specify that your transform is invertible and implement `Base.inv`
Similar to reversibility, falls back to false by default. We can write that explicitly here since `Standardize` has no inverse if we are given nothing except for the table.

```julia
TransformsBase.isinvertible(::Type{Standardize}) = false
```

If an arbitrary transform `T` is invertible we can rather specify that as true and follow up by implementing `Base.inv(::T)` which would be expected to return an instance of the inverse transform. For instance, for an identity transform we can do
```julia
# interface struct
struct Identity <: Transform end
# specify that it is invertible
TransformsBase.isinvertible(::Type{Identity}) = true
# implement Base.inv
Base.inv(::Identity) = Identity()
```
which implies that `inv(Identity())` would return an identity transform.
```@meta
CurrentModule = TableTransforms
```

# TableTransforms.jl

## Overview

This package provides transforms that are commonly used in statistics
and machine learning. It was developed to address specific needs in
feature engineering and works with general
[Tables.jl](https://github.com/JuliaData/Tables.jl) tables.

Past attempts to model transforms in Julia such as
[FeatureTransforms.jl](https://github.com/invenia/FeatureTransforms.jl)
served as inspiration for this package. We are happy to absorb any
missing transform, and contributions are very welcome.

## Features

- Transforms are **revertible** meaning that one can apply a transform
  and undo the transformation without having to do all the manual work
  keeping constants around.

- Pipelines can be easily constructed with clean syntax
  `(f1 → f2 → f3) ⊔ (f4 → f5)`, and they are automatically
  revertible when the individual transforms are revertible.

- Branches of a pipeline and colwise transforms are run in parallel
  using multiple threads with the awesome
  [Transducers.jl](https://github.com/JuliaFolds/Transducers.jl)
  framework.

- Pipelines can be reapplied to unseen "test" data using the same cache
  (e.g. constants) fitted with "training" data. For example, a `ZScore`
  relies on "fitting" `μ` and `σ` once at training time.

## Rationale

A common task in statistics and machine learning consists of transforming
the variables of a problem to achieve better convergence or to apply methods
that rely on multivariate Gaussian distributions. This process can be quite
tedious to implement by hand and very error-prone. We provide a consistent
and clean API to combine statistical transforms into pipelines.

*Although most transforms discussed here come from the statistical domain,
our long term vision is more ambitious. We aim to provide a complete
user experience with fully-featured pipelines that include standardization
of column names, imputation of missing data, and more.*

## Installation

Get the latest stable release with Julia's package manager:

```julia
] add TableTransforms
```

## Usage

Below is a quick example with simple transforms:

```@example usage
using TableTransforms
using Plots, PairPlots
using Distributions
using Random; Random.seed!(2) # hide
gr(format=:png) # hide

# example table from PairPlots.jl
N = 100_000
a = [2randn(N÷2) .+ 6; randn(N÷2)]
b = [3randn(N÷2); 2randn(N÷2)]
c = randn(N)
d = c .+ 0.6randn(N)
table = (; a, b, c, d)

# corner plot of original table
table |> corner
```

```@example usage
# convert to PCA scores
table |> PCA() |> corner
```

```@example usage
# convert to any Distributions.jl
table |> Quantile(Normal()) |> corner
```

Below is a more sophisticated example with a pipeline that has
two parallel branches. The tables produced by these two branches
are concatenated horizontally in the final table:

```@example usage
# create a transform pipeline
f1 = ZScore()
f2 = Scale()
f3 = Quantile()
f4 = Functional(cos)
f5 = Interquartile()
pipeline = (f1 → f2 → f3) ⊔ (f4 → f5)

# feed data into the pipeline
table |> pipeline |> corner
```

### Apply and Revert

To revert a pipeline or single transform, use the `apply` and `revert`
functions instead:

```@docs
apply
revert
isrevertible
```

To exemplify the use of these functions, let's create a table:

```@example usage2
using TableTransforms
using DataFrames
using Random; Random.seed!(2) # hide

a = rand(6)
b = 3rand(6)
c = 2rand(6)
table = DataFrame(; a, b, c)
```

\
Now, let's choose a transform and check if it is reversible:

```@example usage2
transform = Center()
isrevertible(transform)
```

We apply the transformation to the table and save the cache in a variable:

```@example usage2
newtable, cache = apply(transform, table)
newtable
```

\
Using the cache we can reverse the transform:

```@example usage2
original = revert(transform, newtable, cache)
```

\
Finally, it is sometimes useful to `reapply` a transform that was
"fitted" with training data to unseen test data. In this case, the
cache from a previous `apply` call is used:

```@docs
reapply
```

Example:

```julia
# ZScore transform "fits" μ and σ using training data
newtable, cache = apply(ZScore(), traintable)

# we can reuse the same values of μ and σ with test data
newtable = reapply(ZScore(), testtable, cache)
```
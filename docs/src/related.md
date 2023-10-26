# Related

- [FeatureTransforms.jl](https://github.com/invenia/FeatureTransforms.jl)
  has transforms, but they are not fully revertible. Some of their
  transforms such as `MeanStdScaling` are constructed for a specific
  table and cannot be inserted in the middle of a pipeline for example.
- [AutoMLPipeline.jl](https://github.com/IBM/AutoMLPipeline.jl) relies on
  the Python stack via [PyCall.jl](https://github.com/JuliaPy/PyCall.jl).
  They provide pipelines with Julia's pipe `|>` operator and follow a
  more "Pythonic" interface. They do not support general
  [Tables.jl](https://github.com/JuliaData/Tables.jl).
- [Impute.jl](https://github.com/invenia/Impute.jl),
  [Cleaner.jl](https://github.com/TheRoniOne/Cleaner.jl),
  [DataConvenience.jl](https://github.com/xiaodaigh/DataConvenience.jl)
  all have a small set of transforms related to fixing column names as
  well as other basic transforms that we plan to absorb in the long term.
- [DataFramesMeta.jl](https://github.com/jkrumbiegel/Chain.jl) is a package
  to manipulate [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl)
  tables. It is not intended for statistical transforms such as `PCA`,
  `Quantile`, etc, which rely on complex interactions between the rows and
  columns of a table. The usage of macros in the package promotes one-shot
  scripts as opposed to general pipelines that can be passed around to
  different places in the program.
- [Query.jl](https://github.com/queryverse/Query.jl) is a package to query
  [IterableTables.jl](https://github.com/queryverse/IterableTables.jl).
  Similar to other alternatives above, the package is not intended for
  advanced statistical transforms.
- [MLJ.jl](https://alan-turing-institute.github.io/MLJ.jl/dev/) is a
  popular machine learning framework in Julia that adopts a different
  design for pipelines based on mutability of structs.
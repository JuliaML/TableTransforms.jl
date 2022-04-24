using TableTransforms
using Documenter

DocMeta.setdocmeta!(TableTransforms, :DocTestSetup, :(using TableTransforms); recursive=true)

makedocs(;
  modules=[TableTransforms],
  authors="Júlio Hoffimann <julio.hoffimann@gmail.com> and contributors",
  repo="https://github.com/JuliaML/TableTransforms.jl/blob/{commit}{path}#{line}",
  sitename="TableTransforms.jl",
  format=Documenter.HTML(;
    prettyurls=get(ENV, "CI", "false") == "true",
    canonical="https://JuliaML.github.io/TableTransforms.jl",
    assets=String[]
  ),
  pages=[
    "Home" => "index.md",
    "Reference guide" => [
      "Using transforms" => "usingtransforms.md",
      "Transforms" => [
        "Data Manipulation" => "transforms/datamanipulation.md",
        "Statistic" => "transforms/statistic.md",
        "Pipelines" => "transforms/pipelines.md"
      ],
      "Traits" => "traits.md"
    ],
    "Index" => "links.md"
  ]
)

deploydocs(;
  repo="github.com/JuliaML/TableTransforms.jl",
  devbranch="master"
)

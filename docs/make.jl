using Documenter, TableTransforms

using TransformsBase

makedocs(;
  warnonly=[:missing_docs],
  modules=[TableTransforms, TransformsBase],
  format=Documenter.HTML(prettyurls=get(ENV, "CI", "false") == "true"),
  sitename="TableTransforms.jl",
  authors="Júlio Hoffimann, Elias Carvalho",
  pages=[
    "Home" => "index.md",
    "Transforms" => "transforms.md",
    "Developer guide" => "devguide.md",
    "Related" => "related.md"
  ]
)

deploydocs(;
  repo="github.com/JuliaML/TableTransforms.jl",
  versions=["stable" => "v^", "dev" => "dev"]
)

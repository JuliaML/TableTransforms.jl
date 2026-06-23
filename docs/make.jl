using Documenter, TableTransforms

using TransformsBase

makedocs(;
  warnonly=[:missing_docs],
  modules=[TableTransforms, TransformsBase],
  authors="Júlio Hoffimann <julio.hoffimann@gmail.com> and contributors",
  repo="https://github.com/JuliaML/TableTransforms.jl/blob/{commit}{path}#{line}",
  sitename="TableTransforms.jl",
  format=Documenter.HTML(;
    prettyurls=get(ENV, "CI", "false") == "true",
    canonical="https://JuliaML.github.io/TableTransforms.jl",
    repolink="https://github.com/JuliaML/TableTransforms.jl"
  ),
  pages=[
    "Home" => "index.md",
    "Transforms" => "transforms.md",
    "Developer guide" => "devguide.md",
    "Related" => "related.md"
  ]
)

deploydocs(;
  repo="github.com/JuliaML/TableTransforms.jl",
  versions=["stable" => "v^", "dev" => "dev"],
  devbranch="master",
  push_preview=true
)

using TableTransforms
using TransformsAPI
using Documenter

DocMeta.setdocmeta!(TableTransforms, :DocTestSetup, :(using TableTransforms); recursive=true)

# Workaround for GR warnings
ENV["GKSwstype"] = "100"

makedocs(;
  modules=[TableTransforms, TransformsAPI],
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
    "Transforms" => [
      "transforms/builtin.md",
      "transforms/external.md"
    ],
    "related.md"
  ]
)

deploydocs(;
  repo="github.com/JuliaML/TableTransforms.jl",
  devbranch="master",
  push_preview=true
)

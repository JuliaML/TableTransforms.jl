using Documenter, TableTransforms
using DocumenterTools: Themes

using TransformsBase

DocMeta.setdocmeta!(TableTransforms, :DocTestSetup, :(using TableTransforms); recursive=true)

# Workaround for GR warnings
ENV["GKSwstype"] = "100"

makedocs(;
  warnonly=[:missing_docs, :cross_references],
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

deploydocs(; repo="github.com/JuliaML/TableTransforms.jl", devbranch="master", push_preview=true)

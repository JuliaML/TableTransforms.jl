using Documenter, TableTransforms
using DocumenterTools: Themes

using TransformsBase

Themes.compile(
  joinpath(@__DIR__, "src/assets/light.scss"),
  joinpath(@__DIR__, "src/assets/themes/documenter-light.css")
)
Themes.compile(joinpath(@__DIR__, "src/assets/dark.scss"), joinpath(@__DIR__, "src/assets/themes/documenter-dark.css"))

DocMeta.setdocmeta!(TableTransforms, :DocTestSetup, :(using TableTransforms); recursive=true)

# Workaround for GR warnings
ENV["GKSwstype"] = "100"

makedocs(;
  modules=[TableTransforms, TransformsBase],
  authors="Júlio Hoffimann <julio.hoffimann@gmail.com> and contributors",
  repo="https://github.com/JuliaML/TableTransforms.jl/blob/{commit}{path}#{line}",
  sitename="TableTransforms.jl",
  format=Documenter.HTML(;
    prettyurls=get(ENV, "CI", "false") == "true",
    canonical="https://JuliaML.github.io/TableTransforms.jl",
    assets=[
      "assets/favicon.ico",
      asset("https://fonts.googleapis.com/css?family=Montserrat|Source+Code+Pro&display=swap", class=:css)
    ]
  ),
  pages=["Home" => "index.md", "Transforms" => "transforms.md", "Related" => "related.md"]
)

deploydocs(; repo="github.com/JuliaML/TableTransforms.jl", devbranch="master", push_preview=true)

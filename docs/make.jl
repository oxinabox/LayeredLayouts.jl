using LayeredLayouts
using Documenter

makedocs(;
    modules=[LayeredLayouts],
    authors="Lyndon White <lyndon.white@invenialabs.co.uk> and contributors",
    repo="https://github.com/oxinabox/LayeredLayouts.jl/blob/{commit}{path}#L{line}",
    sitename="LayeredLayouts.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://oxinabox.github.io/LayeredLayouts.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/oxinabox/LayeredLayouts.jl",
)

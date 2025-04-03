using Pkg
Pkg.activate(@__DIR__)
using Documenter, NCDatasets, CommonDataModel, UUIDs

CommonDataModel_path = realpath(joinpath(dirname(pathof(CommonDataModel)),".."))
CommonDataModel_remote = (
    Remotes.GitHub("JuliaGeo","CommonDataModel.jl"),
    string("v",Pkg.dependencies()[UUID("1fbeeb36-5f17-413c-809b-666fb144f157")].version))


makedocs(
    modules = [NCDatasets, CommonDataModel],
    remotes = Dict(
        CommonDataModel_path => CommonDataModel_remote,
    ),
    sitename = "NCDatasets.jl",
    doctest = false,
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical = "https://juliageo.github.io/NCDatasets.jl",
    ),
    pages = [
        "Introduction" => "index.md",
        "Datasets" => "dataset.md",
        "Dimensions" => "dimensions.md",
        "Variables" => "variables.md",
        "Attributes" => "attributes.md",
        "Performance tips" => "performance.md",
        "Other features" => "other.md",
        "Known issues" => "issues.md",
        "Tutorials" => "tutorials.md",
    ],
    checkdocs = :none,
)

deploydocs(repo = "github.com/JuliaGeo/NCDatasets.jl.git")

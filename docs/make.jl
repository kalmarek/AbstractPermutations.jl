using AbstractPermutations
using Documenter

DocMeta.setdocmeta!(
    AbstractPermutations,
    :DocTestSetup,
    :(using AbstractPermutations);
    recursive = true,
)

makedocs(;
    modules = [AbstractPermutations],
    authors = "Marek Kaluba <kalmar@mailbox.org>",
    repo = "https://github.com/kalmarek/AbstractPermutations.jl/blob/{commit}{path}#{line}",
    sitename = "AbstractPermutations.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://kalmarek.github.io/AbstractPermutations.jl",
        edit_link = "main",
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
        "`AbstractPermutation` interface" => "abstract_api.md",
        "Other functions" => "misc.md",
    ],
    warnonly = [:missing_docs],
)

deploydocs(;
    repo = "github.com/kalmarek/AbstractPermutations.jl",
    devbranch = "main",
)

using Documenter
using AstrodynamicalSurogates

makedocs(
    sitename = "AstrodynamicalSurogates",
    format = Documenter.HTML(),
    modules = [AstrodynamicalSurogates]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#

using Documenter
using SolarSystemSurrogates

makedocs(
    sitename = "SolarSystemSurrogates",
    format = Documenter.HTML(),
    modules = [SolarSystemSurrogates]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#

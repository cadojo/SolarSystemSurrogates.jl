"""
NAIF IDs for common solar system bodies! All IDs are pulled directly from the following URL:

https://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/req/frames.html

# Extended Help

## Imports 

$(IMPORTS)

## Exports 

$(EXPORTS)
"""
module NAIF

export barycenters, planets, spacecraft, comets, asteroids, groundstations

using DocStringExtensions, CSV, DataFrames

makeframe(x) = DataFrame(CSV.File(joinpath(@__DIR__, "..", "..", "build", "NAIF", x)))

const barycenters    = makeframe("Barycenters.csv")
const planets        = makeframe("Planets.csv")
const spacecraft     = makeframe("Spacecraft.csv")
const comets         = makeframe("Comets.csv")
const asteroids      = makeframe("Asteroids.csv")
const groundstations = makeframe("GroundStations.csv")

end # module
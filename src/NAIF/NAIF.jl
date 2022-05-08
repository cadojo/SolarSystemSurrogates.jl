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

using Memoize 

export barycenters, planets, spacecraft, comets, asteroids, groundstations

using DocStringExtensions, CSV, DataFrames

makeframe(x) = DataFrame(CSV.File(joinpath(@__DIR__, "..", "..", "build", "NAIF", x)))

barycenter()     = makeframe("Barycenters.csv")
planets()        = makeframe("Planets.csv")
spacecraft()     = makeframe("Spacecraft.csv")
comets()         = makeframe("Comets.csv")
asteroids()      = makeframe("Asteroids.csv")
groundstations() = makeframe("GroundStations.csv")

end # module
## AstrodynamicalSurrogates.jl
_Surrogate models trained on solar system ephemeris data, so you don't have to download gigabytes of data!_

### Usage

```julia
# Load the package...
using AstrodynamicalSurogates

# Optionally, load Dates (or better yet, AstroTime 😉)
using Dates, AstroTime

# ...and use a surrogate!
x, y, z, ẋ, ẏ, ż = cartesianstate = Earth(now())

# All states are, by default, with respect to the solar system barycenter
EarthWartSun = Earth(now()) - Sun(now())

# Plop one of these into AstrodynamicalModels.NBPEphemeris, and 
# you have an n-body ephemeris model out of the box! In fact,
# all you need to do is _load_ AstrodynamicalModels, and it 
# will use AstrodynamicalSurogates by default
using AstrodynamicalModels
model = NBPEphemeris()
```

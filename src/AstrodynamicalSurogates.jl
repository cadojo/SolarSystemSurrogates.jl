"""
Tired of downloading ephemeris data? These surrogate models were trained on solar system ephemeris data _for you_!

# Extended Help

$(README)

## License

$(LICENSE)

## Exports

$(EXPORTS)

## Imports

$(IMPORTS)
```
"""
module AstrodynamicalSurogates

export NAIF

using DocStringExtensions

include(joinpath("NAIF", "NAIF.jl"))
import .NAIF

end # module

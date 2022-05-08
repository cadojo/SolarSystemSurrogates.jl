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
module SolarSystemSurrogates

using DocStringExtensions

@template DEFAULT =
    """
    $(SIGNATURES)
    $(DOCSTRING)
    """

@template (FUNCTIONS, METHODS, MACROS) =
    """
    $(SIGNATURES)
    $(DOCSTRING)
    $(METHODLIST)
    """

using Dates
using SPICE
using HORIZONS
using AstroTime
using DataFrames
using StaticArrays
using Interpolations

export naifid, fetchephemeris



"""
Return the NAIF ID for the provided celestial body name. If no ID for 
the provided body is found, a `KeyError` exception is thrown.

!!! note
    This is a simple wrapper around `SPICE.bodn2c`, which is itself 
    a wrapper around the CSPICE library's `bod2nc` function! This 
    integer code lookup is robust to different capitalizations. 
    For example, `"Earth"`, `"earth"`, and `"eArTH"` should all return 
    integer code `399`.
"""
function naifid(name::AbstractString)
    code = SPICE.bodn2c(name)

    if code isa Integer
        return code
    else
        throw(KeyError("No NAIF ID for $name could be found!"))
    end
end

"""
Given a celestial body's name, or the NAIF ID of the body,
return a DataFrame of ephemeris data for the specified 
`timespan` and `intervol` between time steps.
"""
function fetchephemeris(
        body::Union{<:AbstractString, <:Integer}, 
        timespan::Tuple{<:Dates.AbstractDateTime, <:Dates.AbstractDateTime} = (now() - Year(5), now() + Year(5)),
        intervol::Dates.Period = Day(1),
        type = Float64; 
        email = "", 
        wrt = "@ssb", 
        epoch = "J2000", 
        interpolate = Val{true},
    )

    ID = body isa AbstractString ? naifid(body) : body

    options = (
        EMAIL_ADDR = email,
        CENTER = wrt,
        REF_SYSTEM = epoch,
        REF_PLANE = "FRAME", 
        CSV_FORMAT = true, 
        VEC_TABLE = 2, 
        VEC_CORR = 1, 
        OUT_UNITS = 1, 
        VEC_LABELS = false, 
        VEC_DELTA_T = false, 
    )

    data, = vec_tbl_csv(ID, timespan[1], timespan[2], intervol; options...)

    if data[1,:] == ["JDTDB", "Calendar_Date_TDB", "X", "Y", "Z", "VX", "VY", "VZ"]
        ephemeris = DataFrame(
            :dⱼ => type.(data[2:end,1]),
            :x  => type.(data[2:end,3]),
            :y  => type.(data[2:end,4]),
            :z  => type.(data[2:end,5]),
            :ẋ  => type.(data[2:end,6]),
            :ẏ  => type.(data[2:end,7]),
            :ż  => type.(data[2:end,8]),
        )
    else
        @warn "Invalid columns! $(data[1,:])"
        throw(ErrorException("Ephemeris data downloaded successfully, but the column format is different than expected!"))
    end

    if interpolate == Val{true}
        return EphemerisInterpolation(ephemeris)
    else
        return ephemeris
    end

end

abstract type AbstractEphemerisInterpolation end

struct EphemerisInterpolation{F<:AbstractFloat, TX<:CubicHermite, TY<:CubicHermite, TZ<:CubicHermite} <:AbstractEphemerisInterpolation
    timespan::Tuple{F,F}
    X::TX
    Y::TY
    Z::TZ
end

function EphemerisInterpolation(data::DataFrame)

    F = promote_type(
        eltype(data.dⱼ),
        eltype(data.x),
        eltype(data.y),
        eltype(data.z),
        eltype(data.ẋ),
        eltype(data.ẏ),
        eltype(data.ż),
    )

    timespan = (
        F(data.dⱼ[1]),
        F(data.dⱼ[end]),
    )

    X = CubicHermite(data.dⱼ, data.x, data.ẋ)
    Y = CubicHermite(data.dⱼ, data.y, data.ẏ)
    Z = CubicHermite(data.dⱼ, data.z, data.ż)

    return EphemerisInterpolation{F, typeof(X), typeof(Y), typeof(Z)}(
        timespan, X, Y, Z
    )
end

function (ephemeris::EphemerisInterpolation{F})(timepoint::Number; type = SVector{6,F}) where F <: AbstractFloat
    t = timepoint isa F ? timepoint : F(timepoint)
    return (
        ephemeris.X(t),
        ephemeris.Y(t),
        ephemeris.Z(t),
        gradient(ephemeris.X, t),
        gradient(ephemeris.Y, t),
        gradient(ephemeris.Z, t),
    ) |> type
end

function Base.show(io::IO, ephemeris::EphemerisInterpolation{F}) where F <: AbstractFloat
    print(io, "Cubic Hermite interpolation of ephemeris data with eltype $F")
end

"""
Produces a Lagrange polynomial expression which is equal to the provided 
`y` data at each point in `x`. 

# Extended Help

See the [Wolfram website](https://mathworld.wolfram.com/LagrangeInterpolatingPolynomial.html)
for more information about Lagrange polynomials, and other appoximation methods!
"""
function lagrangepolynomial(x::AbstractVector, y::AbstractVector, z::Number = Symbolics.variable(:z))

    n = length(x)

    δⱼ(z,x,j,k) = (z - x[k]) / (x[j] - x[k])
    Pⱼ(z,x,j,n) = prod(δⱼ(z,x,j,k) for k in 1:n if k != j)

    return sum(map(j -> y[j] * Pⱼ(z,x,j,n), 1:n))
    
end

end # module

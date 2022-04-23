#
# Helper functions to build NAIF DataFrames.
#

using CSV, DataFrames

"""
Converts a string of NAIF ID data to a DataFrame. Find NAIF IDs at the following URL!

https://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/req/naif_ids.html
"""
function process(str::AbstractString; label::Union{<:AbstractString, Symbol} = "")::DataFrame
    lines = split(str, "\n")
    filter!(!isempty, lines)

    if occursin("NAIF ID", lines[1]) && occursin("NAME", lines[1])
        lines = lines[3:end]
    end

    data = [split(line, "'") for line in lines]

    if label isa AbstractString && isempty(label)
        return DataFrame(
            :NAIF => [parse(Int, d[1]) for d in data],
            :Name => [string(d[2]) for d in data],
        )
    else
        return DataFrame(
            :NAIF => [parse(Int, d[1]) for d in data],
            :Name => [string(d[2]) for d in data],
            Symbol(label) => [string(strip(d[3])) for d in data],
        )
    end
end
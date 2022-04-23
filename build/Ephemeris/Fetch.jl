#
# Fetch ephemeris data!
#

"""
NOTE: check the JPL documentation and license information to see if 
your desired usage meets all required terms!
"""

function fetchephemeris(NAIF_ID::Int, filename::AbstractString)

    fetch  = `$(joinpath(@__DIR__, "vec_tbl")) $(NAIF_ID) $(filename)`
    clean  = pipeline(`sed -n '/\$\$SOE/,/\$\$EOE/{//!p;}' $(filename)`, `sponge $(filename)`)
    format = pipeline(`awk -F , 'BEGIN {OFS=FS}  {$2=""; sub(",,", ","); print}' $(filename)`, `sponge $(filename)`)

    try
        run(fetch)
    catch e 
        @error "Failed to fetch ephemeris data for NAIF ID $(NAIF_ID)!"
        throw(e)
    end

    try
        run(clean)
        run(format)
    catch e 
        @error "Failed to format ephemeris data for NAIF ID $(NAIF_ID)!"
        throw(e)
    end

    return nothing
end
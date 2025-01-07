
"""
Symbolic parameter, see [`Par`](@ref), representing
the exergy environment temperature with
a (default) value of 300K.
"""
const θ₀ = Par(DtryPath(:ENV), DtryPath(:θ), 300.)


"""
Symbolic parameter, see [`Par`](@ref), representing
the exergy environment pressuere with
a (default) value of 10⁵Pa.
"""
const π₀ = Par(DtryPath(:ENV), DtryPath(:π), 10^5.)

module TestSimulations

using Test, EPHS, StaticArrays

include("nlsolve.jl")

using ..TestCompositeSystems: pe, ke, pkc, c

include("osc.jl") # mechanical oscillator
include("osc_constraint_masses.jl")  # mechanical oscillator with two masses (in parallel)
include("osc_constraint_springs.jl") # mechanical oscillator with two springs in series

include("cpd.jl") # cylinder-piston device

end

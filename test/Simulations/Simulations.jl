module TestSimulations

using Test, EPHS, StaticArrays

include("nlsolve.jl")

include("osc.jl") # mechanical oscillator
# include("osc_constraint.jl") # mechanical oscillator with two springs in series

end

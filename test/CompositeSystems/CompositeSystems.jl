module TestCompositeSystems

using Test, EPHS

include("osc.jl") # mechanical oscillator
include("osc_damped_flat.jl") # oscillator with mechanical friction and thermal capacity
include("osc_damped_lever.jl") # damped oscillator with displacement transformer (lever)
include("osc_damped_nested.jl") # damped oscillator with undamped oscillator as subsystem
include("osc_constraint.jl") # mechanical oscillator with two springs in series


include("motor.jl") # DC shunt motor

end

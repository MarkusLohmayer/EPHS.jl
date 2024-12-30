"""
A mixed bag of core functionality related to systems
"""
module AbstractSystems

export Quantity
export PortType
export Interface
export AbstractSystem
export interface, fillcolor

# Pre-defined quantities
export displacement, momentum, angular_momentum
export entropy
export charge, magnetic_flux

# Port variables
export PortVar, PowerVar
export XVar, FVar, EVar


using ..Directories
using ..SymbolicExpressions


struct Quantity
  quantity::Symbol
  space::Symbol
end


include("quantities.jl")


struct PortType
  quantity::Quantity
  power::Bool
end


const Interface = Dtry{PortType}


abstract type AbstractSystem end


# API for systems
interface(::AbstractSystem) = error("not implemented")
fillcolor(::AbstractSystem) = error("not implemented")


include("port_variables.jl")

end

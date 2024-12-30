module Components

export Component
export StorageComponent, ReversibleComponent, IrreversibleComponent

export HookeanSpring, PointMass, AngularMass, ThermalCapacity, Coil
export PKC, Lever, EMC, MKC
export LinearFriction, LinearRotationalFriction, LinearResistance


using ..Directories
using ..SymbolicExpressions
using ..AbstractSystems
using ..Environment


# Type hierarchy for components
abstract type Component <: AbstractSystem end
abstract type StorageComponent <: Component end
abstract type ReversibleComponent <: Component end
abstract type IrreversibleComponent <: Component end


# Colors for visualization of patterns
AbstractSystems.fillcolor(::StorageComponent) = "#5082B0"
AbstractSystems.fillcolor(::ReversibleComponent) = "#3DB57B"
AbstractSystems.fillcolor(::IrreversibleComponent) = "#FF7F80"


"""
Get value of port variable, as determined by the component.
If the port does not determine the variable, `nothing` is returned.
"""
Base.get(::Component, ::PortVar; resolve=identity) = nothing


# Pre-defined components
include("storage.jl")
include("reversible.jl")
include("irreversible.jl")

end

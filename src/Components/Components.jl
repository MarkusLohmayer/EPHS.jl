module Components

export Component
export StorageComponent, ReversibleComponent, IrreversibleComponent

export HookeanSpring, PointMass, ThermalCapacity
export PKC, Lever
export LinearFriction

# export energy
# export flow, effort


using ..Directories
using ..SymbolicExpressions
using ..AbstractSystems
using ..Environment


# Type hierarchy for components
abstract type Component <: AbstractSystem end
abstract type StorageComponent <: Component end
abstract type ReversibleComponent <: Component end
abstract type IrreversibleComponent <: Component end


# # API for components
# energy(::StorageComponent) = error("Not implemented")
# effort(::StorageComponent) = error("Not implemented")
# flow(::ReversibleComponent) = error("Not implemented")
# flow(::IrreversibleComponent) = error("Not implemented")


# Colors for visualization of patterns
AbstractSystems.fillcolor(::StorageComponent) = "#5082B0"
AbstractSystems.fillcolor(::ReversibleComponent) = "#3DB57B"
AbstractSystems.fillcolor(::IrreversibleComponent) = "#FF7F80"


# Pre-defined components
include("storage.jl")
include("reversible.jl")
include("irreversible.jl")

end

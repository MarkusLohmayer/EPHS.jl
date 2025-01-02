module Components

export Component
export StorageComponent, StoragePort
export ReversibleComponent, ReversiblePort, FlowPort, EffortPort, StatePort
export IrreversibleComponent, IrreversiblePort
export provides, provide


using ..Directories
using ..SymbolicExpressions
using ..AbstractSystems


abstract type Component <: AbstractSystem end


provides(::Component, ::PortVar) = false


include("storage.jl")
include("reversible.jl")
include("irreversible.jl")

end

"""
The `Components` module defines the primitive systems:
[`StorageComponent`](@ref)s,
[`ReversibleComponent`](@ref)s, and
[`IrreversibleComponent`](@ref)s.
"""
module Components

export Component
export Par
export θ₀, π₀
export StorageComponent, StoragePort
export ReversibleComponent, ReversiblePort, FlowPort, EffortPort, StatePort
export Constraint, CVar
export IrreversibleComponent, IrreversiblePort
export provides, provide
export expr_energy, expr_entropy


using ..Directories
using ..SymbolicExpressions
using ..AbstractSystems


"""
`Component` is a subtype of
[`EPHS.AbstractSystems.AbstractSystem`](@ref).
Concrete subtypes of `Component` are
[`StorageComponent`](@ref),
[`ReversibleComponent`](@ref), and
[`IrreversibleComponent`](@ref).
"""
abstract type Component <: AbstractSystem end


provides(::Component, ::PortVar)::Bool = false


AbstractSystems.total_energy(::Component; box_path::DtryPath=■) = Const(0.)
AbstractSystems.total_entropy(::Component; box_path::DtryPath=■) = Const(0.)


Base.show(io::IO, ::MIME"text/plain", c::Component) = print(io, c)


include("parameters.jl")
include("environment.jl")

include("storage.jl")
include("reversible.jl")
include("irreversible.jl")

end

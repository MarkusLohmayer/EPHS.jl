"""
The `AbstractSystems` module provides a common basis
for the graphical syntax defined in [`EPHS.Patterns`](@ref)
and the semantics defined in [`EPHS.Components`](@ref) and [`EPHS.CompositeSystems`](@ref).
Specifically, the module defines
system interfaces (see [`Interface`](@ref)),
an abstract type for concrete systems (see [`AbstractSystem`](@ref)),
and port variables (see [`PortVar`](@ref)).
"""
module AbstractSystems

export Quantity
export PortType
export Interface
export AbstractSystem
export interface, fillcolor
export total_energy, total_entropy

# Pre-defined quantities
export displacement
export momentum, angular_momentum
export entropy
export charge
export magnetic_flux
export volume

# Port variables
export PortVar, PowerVar
export XVar, FVar, EVar

# Semantics
export relation
export StateProvider, StateConsumer
export FlowProvider, EffortProvider
export Port
export Relation


using ..Directories
using ..SymbolicExpressions


"""
    Quantity(quantity::Symbol, space::Symbol, iseven::Bool)

A `Quantity` represents a physical quantity
and is used to define a [`PortType`](@ref).

# Fields
- `quantity`: `Symbol` identifying the quantity, e.g. `:momentum`
- `space`: `Symbol` identifying its state space, e.g. `:ℝ`
- `iseven`: `false` means the quantity has odd parity w.r.t. time reversal transformation
"""
struct Quantity
  quantity::Symbol
  space::Symbol
  iseven::Bool
end


Base.string(quantity::Quantity) =
  "($(quantity.quantity), $(quantity.space))"


include("quantities.jl")


"""
    PortType(quantity::Quantity, power::Bool)

Next to its name (i.e. [`DtryPath`](@ref), see [`Interface`](@ref)),
a port is defined by its `PortType`,
see also [`Interface`](@ref).

# Fields
- `quantity`: only ports with the same [Quantity](@ref) can be connected
- `power`: `false` means state port, `true` means power port

State ports only have a state variable to share information about
the given quantity, e.g. the amount of magnetic flux.
Power ports additionally have a flow and an effort variable
whose pairing yields the power that is exchanged via the port.
"""
struct PortType
  quantity::Quantity
  power::Bool
end


"""
The interface of a system
is basically a directory (see [`Dtry`](@ref)) of ports.
Hence, each port of an `Interface`
is addressed by its name (i.e. [`DtryPath`](@ref))
and it has assigned to it a [`PortType`](@ref).
"""
const Interface = Dtry{PortType}


"""
`AbstractSystem` is a supertype of
[`EPHS.Components.Component`](@ref) (for primitive systems) and
[`EPHS.CompositeSystems.CompositeSystem`](@ref) (for systems composed of subsystems).
"""
abstract type AbstractSystem end


# API for `AbstractSystem`s:

"""
    interface(system::AbstractSystem) -> Interface

Returns the [`Interface`](@ref) of the given system.
"""
interface(::AbstractSystem) = error("not implemented")


"""
    fillcolor(system::AbstractSystem) -> String

Returns the fillcolor of an [`EPHS.Patterns.InnerBox`](@ref),
which is filled by the given system.
The returned `String` is a HTML hex color code.
"""
fillcolor(::AbstractSystem) = error("not implemented")


"""
    relation(system::AbstractSystem) -> Relation

Returns the [Relation](@ref) that defines the semantics of the system.
"""
relation(::AbstractSystem) = error("not implemented")


"""
    total_energy(system::AbstractSystem) -> SymExr

Returns a symbolic expression for the total energy of the system.
"""
total_energy(::AbstractSystem; box_path::DtryPath=■) = error("not implemented")


"""
    total_entropy(system::AbstractSystem) -> SymExr

Returns a symbolic expression for the total entropy of the system.
"""
total_entropy(::AbstractSystem; box_path::DtryPath=■) = error("not implemented")


include("port_variables.jl")


include("relation.jl")

end

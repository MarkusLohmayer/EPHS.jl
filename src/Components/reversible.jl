
"""
    FlowPort(quantity::Quantity, flow::SymExpr)

A `FlowPort` of a [`ReversibleComponent`](@ref)
used to define
a gyrator-like coupling or
a transformer-like coupling
(in combination with a corresponding [`EffortPort`](@ref)).
"""
struct FlowPort
  quantity::Quantity
  flow::SymExpr
end


"""
    EffortPort(quantity::Quantity, effort::SymExpr)

A `EffortPort` of a [`ReversibleComponent`](@ref)
used to define
a transformer-like coupling
(in combination with a corresponding [`FlowPort`](@ref)).
"""
struct EffortPort
  quantity::Quantity
  effort::SymExpr
end


"""
    StatePort(quantity::Quantity)

A `StatePort` of a [`ReversibleComponent`](@ref)
needed if a gyrator/transformer-like coupling or
a constraint depends on a state variable
of a system which is not already connected
via a [`FlowPort`](@ref) or an [`EffortPort`](@ref).
"""
struct StatePort
  quantity::Quantity
end


"""
    Constraint(residual::SymExpr)

The residual is forced to be zero
by the corresponding constraint variable.
"""
struct Constraint
  residual::SymExpr
end


"""
    ReversiblePort(variant::Union{FlowPort,EffortPort,StatePort,Constraint})

A 'port' of a [`ReversibleComponent`](@ref) can be a
- [`FlowPort`](@ref) which provides a flow variable
- [`EffortPort`](@ref) which provides an effort variable
- [`StatePort`](@ref) which consumes a state variable
- [`Constraint`](@ref) which defines a residual and a constraint variable
"""
struct ReversiblePort
  variant::Union{FlowPort,EffortPort,StatePort,Constraint}
end


"""
    ReversibleComponent(ports::Dtry{ReversiblePort})

A `ReversibleComponent` is a primitive system
representing reversible dynamics, transformations, or constraints.

# Fields
- `ports`: directory of [`ReversiblePort`](@ref)s
"""
struct ReversibleComponent <: Component
  ports::Dtry{ReversiblePort}
end


function AbstractSystems.interface(rc::ReversibleComponent)
  filtermap(rc.ports, PortType) do reversible_port
    if reversible_port.variant isa StatePort
      return Some(PortType(reversible_port.variant.quantity, false))
    elseif reversible_port.variant isa Constraint
      return nothing
    else
      return Some(PortType(reversible_port.variant.quantity, true))
    end
  end
end


AbstractSystems.fillcolor(::ReversibleComponent) = "#3DB57B"


function provides(rc::ReversibleComponent, fvar::FVar)
  x = get(rc.ports, fvar.port_path, nothing)
  !isnothing(x) && x.variant isa FlowPort
end


function provides(rc::ReversibleComponent, evar::EVar)
  x = get(rc.ports, evar.port_path, nothing)
  !isnothing(x) && x.variant isa EffortPort
end


function provide(rc::ReversibleComponent, fvar::FVar)
  x = get(rc.ports, fvar.port_path, nothing)
  if !isnothing(x) && x.variant isa FlowPort
    return x.variant.flow
  end
  error("$(string(fvar)) not found")
end


function provide(rc::ReversibleComponent, evar::EVar)
  x = get(rc.ports, evar.port_path, nothing)
  if !isnothing(x) && x.variant isa EffortPort
    return x.variant.effort
  end
  error("$(string(evar)) not found")
end


"Constraint multiplier variable"
struct CVar <: SymVar
  box_path::DtryPath
  port_path::DtryPath
end


CVar(name::Symbol) = CVar(DtryPath(), DtryPath(name))


Base.string(c::CVar) = string(c.box_path * c.port_path)


SymbolicExpressions.ast(cvar::CVar) =
  Symbol(replace(string(cvar), '.' => '₊'))


function Base.print(io::IO, rc::ReversibleComponent)
  println(io, "ReversibleComponent")
  print_dtry(io, rc.ports; print_value=print_port)
end


print_port(io::IO, port::ReversiblePort; prefix::String) =
  print_port(io, port.variant; prefix)


function print_port(io::IO, port::FlowPort; prefix::String)
  println(io, port.quantity)
  print(io, prefix, "f = ", port.flow)
end


function print_port(io::IO, port::EffortPort; prefix::String)
  println(io, port.quantity)
  print(io, prefix, "e = ", port.effort)
end


function print_port(io::IO, port::StatePort; prefix::String)
  print(io, port.quantity, " (state)")
end


function print_port(io::IO, port::Constraint; prefix::String)
  print(io, "constraint: 0 = ", port.residual)
end


"A port of a `ReversibleComponent` which provides the flow variable"
struct FlowPort
  quantity::Quantity
  flow::SymExpr
end


"A port of a `ReversibleComponent` which provides the effort variable"
struct EffortPort
  quantity::Quantity
  effort::SymExpr
end


"A state port of a `ReversibleComponent`"
struct StatePort
  quantity::Quantity
end


struct Constraint
  residual::SymExpr
end


struct ReversiblePort
  variant::Union{FlowPort,EffortPort,StatePort,Constraint}
end


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


Base.string(c::CVar) = string(c.box_path * c.port_path)


CVar(port_name::Symbol) = CVar(DtryPath(), DtryPath(port_name))


function Base.print(io::IO, rc::ReversibleComponent)
  println(io, "ReversibleComponent")
  print_dtry(io, rc.ports; print_value=print_port)
end


print_port(io::IO, port::ReversiblePort, prefix::String) =
  print_port(io, port.variant, prefix)


function print_port(io::IO, port::FlowPort, prefix::String)
  println(io, port.quantity)
  print(io, prefix, "f = ", port.flow)
end


function print_port(io::IO, port::EffortPort, prefix::String)
  println(io, port.quantity)
  print(io, prefix, "e = ", port.effort)
end


function print_port(io::IO, port::StatePort, ::String)
  println(io, port.quantity, " (state)")
end


function print_port(io::IO, port::Constraint, ::String)
  println(io, "constraint: 0 = ", port.residual)
end

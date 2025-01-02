
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


struct ReversiblePort
  variant::Union{FlowPort,EffortPort,StatePort}
end


struct ReversibleComponent <: Component
  ports::Dtry{ReversiblePort}
end


function AbstractSystems.interface(rc::ReversibleComponent)
  map(rc.ports, PortType) do reversible_port
    reversible_port.variant isa StatePort ?
      PortType(reversible_port.variant.quantity, false) :
      PortType(reversible_port.variant.quantity, true)
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

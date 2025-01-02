
"A port of an `IrreversibleComponent` provides the flow variable"
struct IrreversiblePort
  quantity::Quantity
  flow::SymExpr
end


struct IrreversibleComponent <: Component
  ports::Dtry{IrreversiblePort}
end


function AbstractSystems.interface(ic::IrreversibleComponent)
  map(ic.ports, PortType) do irreversible_port
    PortType(irreversible_port.quantity, true)
  end
end


AbstractSystems.fillcolor(::IrreversibleComponent) = "#FF7F80"


provides(ic::IrreversibleComponent, fvar::FVar) =
  haskey(ic.ports, fvar.port_path)


function provide(ic::IrreversibleComponent, fvar::FVar)
  x = get(ic.ports, fvar.port_path, nothing)
  if !isnothing(x)
    return x.flow
  end
  error("$(string(fvar)) not found")
end


"A port of a `StorageComponent` provides the effort variable"
struct StoragePort
  quantity::Quantity
  effort::SymExpr
end


struct StorageComponent <: Component
  ports::Dtry{StoragePort}
end


function AbstractSystems.interface(sc::StorageComponent)
  map(sc.ports, PortType) do storage_port
    PortType(storage_port.quantity, true)
  end
end


AbstractSystems.fillcolor(::StorageComponent) = "#5082B0"


provides(sc::StorageComponent, xvar::XVar) =
  haskey(sc.ports, xvar.port_path)


provides(sc::StorageComponent, evar::EVar) =
  haskey(sc.ports, evar.port_path)


function provide(sc::StorageComponent, xvar::XVar)
  if haskey(sc.ports, xvar.port_path)
    return xvar
  end
  error("$(string(xvar)) not found")
end


function provide(sc::StorageComponent, evar::EVar)
  x = get(sc.ports, evar.port_path, nothing)
  if !isnothing(x)
    return x.effort
  end
  error("$(string(evar)) not found")
end

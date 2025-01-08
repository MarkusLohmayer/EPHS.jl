
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


function Base.print(io::IO, ic::IrreversibleComponent)
  println(io, "IrreversibleComponent")
  print_dtry(io, ic.ports; print_value=print_port)
end


function print_port(io::IO, port::IrreversiblePort, prefix::String)
  println(io, port.quantity)
  print(io, prefix, "f = ", port.flow)
end

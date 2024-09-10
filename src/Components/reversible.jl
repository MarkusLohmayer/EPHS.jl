
struct PKC <: ReversibleComponent end

AbstractSystems.interface(::PKC) = Interface(
  :q => Interface(PortType(displacement, true)),
  :p => Interface(PortType(momentum, true))
)

function Base.get(::PKC, flow::FVar)
  (;box_path, port_path) = flow
  if port_path == DtryPath(:q)
    return -(EVar(box_path, DtryPath(:p)))
  elseif port_path == DtryPath(:p)
    return EVar(box_path, DtryPath(:q))
  else
    error("Port $(effort.port_path) not found")
  end
end

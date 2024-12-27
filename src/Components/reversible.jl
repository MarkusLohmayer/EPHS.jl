
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
    error("Port $(port_path) not found")
  end
end


struct Lever <: ReversibleComponent
  c::Float64
end

AbstractSystems.interface(::Lever) = Interface(
  :q₁ => Interface(PortType(displacement, true)),
  :q₂ => Interface(PortType(displacement, true))
)

function Base.get(lever::Lever, flow::FVar)
  (;box_path, port_path) = flow
  if port_path == DtryPath(:q₁)
    return -(Const(lever.c) * FVar(box_path, DtryPath(:q₂)))
  else
    error("Port $(port_path) not found")
  end
end

function Base.get(lever::Lever, effort::EVar)
  (;box_path, port_path) = effort
  if port_path == DtryPath(:q₂)
    return Const(lever.c) * EVar(box_path, DtryPath(:q₁))
  else
    error("Port $(port_path) not found")
  end
end

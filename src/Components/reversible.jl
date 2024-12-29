
struct PKC <: ReversibleComponent end

AbstractSystems.interface(::PKC) = Interface(
  :q => Interface(PortType(displacement, true)),
  :p => Interface(PortType(momentum, true))
)

function Base.get(::PKC, flow::FVar; resolve=identity)
  (;box_path, port_path) = flow
  if port_path == DtryPath(:q)
    p₊e = EVar(box_path, DtryPath(:p)) |> resolve
    return -p₊e
  elseif port_path == DtryPath(:p)
    q₊e = EVar(box_path, DtryPath(:q)) |> resolve
    return q₊e
  else
    error("Port $(port_path) not found")
  end
end


struct Lever <: ReversibleComponent
  c::SymPar
end

AbstractSystems.interface(::Lever) = Interface(
  :q₁ => Interface(PortType(displacement, true)),
  :q₂ => Interface(PortType(displacement, true))
)

function Base.get(lever::Lever, flow::FVar; resolve=identity)
  (;box_path, port_path) = flow
  c = lever.c
  if port_path == DtryPath(:q₁)
    q₂₊f = FVar(box_path, DtryPath(:q₂)) |> resolve
    return -(c * q₂₊f)
  else
    error("Port $(port_path) not found")
  end
end

function Base.get(lever::Lever, effort::EVar; resolve=identity)
  (;box_path, port_path) = effort
  c = lever.c
  if port_path == DtryPath(:q₂)
    q₁₊e = EVar(box_path, DtryPath(:q₁)) |> resolve
    return c * q₁₊e
  else
    error("Port $(port_path) not found")
  end
end


"Potential-kinetic coupling"
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
  end
  if port_path == DtryPath(:p)
    q₊e = EVar(box_path, DtryPath(:q)) |> resolve
    return q₊e
  end
  nothing
end


"Mechanical lever"
struct Lever <: ReversibleComponent
  c::SymPar
end

AbstractSystems.interface(::Lever) = Interface(
  :q₁ => Interface(PortType(displacement, true)),
  :q₂ => Interface(PortType(displacement, true))
)

function Base.get(lever::Lever, flow::FVar; resolve=identity)
  (;box_path, port_path) = flow
  if port_path == DtryPath(:q₁)
    c = lever.c
    q₂₊f = FVar(box_path, DtryPath(:q₂)) |> resolve
    return -(c * q₂₊f)
  end
  nothing
end

function Base.get(lever::Lever, effort::EVar; resolve=identity)
  (;box_path, port_path) = effort
  if port_path == DtryPath(:q₂)
    c = lever.c
    q₁₊e = EVar(box_path, DtryPath(:q₁)) |> resolve
    return c * q₁₊e
  end
  nothing
end


"Electro-magnetic coupling"
struct EMC <: ReversibleComponent end

AbstractSystems.interface(::EMC) = Interface(
  :q => Interface(PortType(charge, true)),
  :b => Interface(PortType(magnetic_flux, true))
)

function Base.get(::EMC, flow::FVar; resolve=identity)
  (;box_path, port_path) = flow
  if port_path == DtryPath(:q)
    b₊e = EVar(box_path, DtryPath(:b)) |> resolve
    return b₊e
  end
  if port_path == DtryPath(:b)
    q₊e = EVar(box_path, DtryPath(:q)) |> resolve
    return -q₊e
  end
  nothing
end


"Magnetic-kinetic coupling"
struct MKC <: ReversibleComponent end

AbstractSystems.interface(::MKC) = Interface(
  :b => Interface(PortType(magnetic_flux, true)),
  :p => Interface(PortType(angular_momentum, true)),
  :bₛ => Interface(PortType(magnetic_flux, false))
)

function Base.get(::MKC, flow::FVar; resolve=identity)
  (;box_path, port_path) = flow
  if port_path == DtryPath(:b)
    bₛ₊x = XVar(box_path, DtryPath(:bₛ)) |> resolve
    p₊e = EVar(box_path, DtryPath(:p)) |> resolve
    return bₛ₊x * p₊e
  end
  if port_path == DtryPath(:p)
    bₛ₊x = XVar(box_path, DtryPath(:bₛ)) |> resolve
    b₊e = EVar(box_path, DtryPath(:b)) |> resolve
    return -(bₛ₊x * b₊e)
  end
  nothing
end

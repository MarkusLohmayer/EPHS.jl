

struct LinearFriction <: IrreversibleComponent
  d::SymPar
end

AbstractSystems.interface(::LinearFriction) = Interface(
  :p => Interface(PortType(momentum, true)),
  :s => Interface(PortType(entropy, true))
)

function Base.get(lf::LinearFriction, flow::FVar; resolve=identity)
  (;box_path, port_path) = flow
  if port_path == DtryPath(:p)
    d = lf.d
    p₊e = EVar(box_path, DtryPath(:p)) |> resolve
    return d * p₊e
  end
  if port_path == DtryPath(:s)
    d = lf.d
    p₊e = EVar(box_path, DtryPath(:p)) |> resolve
    s₊e = EVar(box_path, DtryPath(:s)) |> resolve
    return -((d * p₊e * p₊e) / (θ₀ + s₊e))
  end
  nothing
end


struct LinearRotationalFriction <: IrreversibleComponent
  d::SymPar
end

AbstractSystems.interface(::LinearRotationalFriction) = Interface(
  :p => Interface(PortType(angular_momentum, true)),
  :s => Interface(PortType(entropy, true))
)

function Base.get(lrf::LinearRotationalFriction, flow::FVar; resolve=identity)
  (;box_path, port_path) = flow
  if port_path == DtryPath(:p)
    d = lrf.d
    p₊e = EVar(box_path, DtryPath(:p)) |> resolve
    return d * p₊e
  end
  if port_path == DtryPath(:s)
    d = lrf.d
    p₊e = EVar(box_path, DtryPath(:p)) |> resolve
    s₊e = EVar(box_path, DtryPath(:s)) |> resolve
    return -((d * p₊e * p₊e) / (θ₀ + s₊e))
  end
  nothing
end


struct LinearResistance <: IrreversibleComponent
  r::SymPar
end

AbstractSystems.interface(::LinearResistance) = Interface(
  :b => Interface(PortType(magnetic_flux, true)),
  :s => Interface(PortType(entropy, true))
)

function Base.get(lr::LinearResistance, flow::FVar; resolve=identity)
  (;box_path, port_path) = flow
  if port_path == DtryPath(:b)
    r = lr.r
    b₊e = EVar(box_path, DtryPath(:b)) |> resolve
    return r * b₊e
  end
  if port_path == DtryPath(:s)
    r = lr.r
    b₊e = EVar(box_path, DtryPath(:b)) |> resolve
    s₊e = EVar(box_path, DtryPath(:s)) |> resolve
    return -((r * b₊e * b₊e) / (θ₀ + s₊e))
  end
  nothing
end

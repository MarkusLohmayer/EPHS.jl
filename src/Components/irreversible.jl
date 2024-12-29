

struct LinearFriction <: IrreversibleComponent
  d::SymPar
end

AbstractSystems.interface(::LinearFriction) = Interface(
  :p => Interface(PortType(momentum, true)),
  :s => Interface(PortType(entropy, true))
)

function Base.get(lf::LinearFriction, flow::FVar; resolve=identity)
  (;box_path, port_path) = flow
  d = lf.d
  if port_path == DtryPath(:p)
    p₊e = EVar(box_path, DtryPath(:p)) |> resolve
    return d * p₊e
  elseif port_path == DtryPath(:s)
    p₊e = EVar(box_path, DtryPath(:p)) |> resolve
    s₊e = EVar(box_path, DtryPath(:s)) |> resolve
    return -((d * p₊e * p₊e) / (θ₀ + s₊e))
  else
    error("Port $(port_path) not found")
  end
end

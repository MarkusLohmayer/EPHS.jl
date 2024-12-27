

struct LinearFriction <: IrreversibleComponent
  d::Float64
end

AbstractSystems.interface(::LinearFriction) = Interface(
  :p => Interface(PortType(momentum, true)),
  :s => Interface(PortType(entropy, true))
)

function Base.get(lf::LinearFriction, flow::FVar)
  (;box_path, port_path) = flow
  d = Const(lf.d)
  p₊e = EVar(box_path, DtryPath(:p))
  s₊e = EVar(box_path, DtryPath(:s))
  if port_path == DtryPath(:p)
    return d * p₊e
  elseif port_path == DtryPath(:s)
    return -((d * p₊e * p₊e) / (θ₀ + s₊e))
  else
    error("Port $(port_path) not found")
  end
end

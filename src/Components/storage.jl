
struct HookeanSpring <: StorageComponent
  k::SymPar
end

AbstractSystems.interface(::HookeanSpring) = Interface(
  :q => Interface(PortType(displacement, true))
)

# function energy(spring::HookeanSpring)
#   q = XVar(:q)
#   k = spring.k
#   Const(0.5) * k * q * q
# end

function Base.get(spring::HookeanSpring, effort::EVar; resolve=identity)
  (;box_path, port_path) = effort
  if port_path == DtryPath(:q)
    q = XVar(box_path, port_path)
    k = spring.k
    return k * q
  else
    error("Port $(port_path) not found")
  end
end


struct PointMass <: StorageComponent
  m::SymPar
end

AbstractSystems.interface(::PointMass) = Interface(
  :p => Interface(PortType(momentum, true))
)

# function energy(mass::PointMass)
#   p = XVar(:p)
#   m = mass.m
#   Const(0.5) / m * p * p
# end

function Base.get(mass::PointMass, effort::EVar; resolve=identity)
  (;box_path, port_path) = effort
  if port_path == DtryPath(:p)
    p = XVar(box_path, port_path)
    m = mass.m
    return p / m
  else
    error("Port $(port_path) not found")
  end
end


struct ThermalCapacity <: StorageComponent
  c₁::SymPar
  c₂::SymPar
end

AbstractSystems.interface(::ThermalCapacity) = Interface(
  :s => Interface(PortType(entropy, true))
)

# function energy(tc::ThermalCapacity)
#   s = XVar(:s)
#   c₁ = tc.c₁
#   c₂ = tc.c₂
#   c₁ * exp(s / c₂)
# end

function Base.get(tc::ThermalCapacity, effort::EVar; resolve=identity)
  (;box_path, port_path) = effort
  if port_path == DtryPath(:s)
    s = XVar(box_path, port_path)
    c₁ = tc.c₁
    c₂ = tc.c₂
    θ = c₁ / c₂ * exp(s / c₂)
    return θ - θ₀
  else
    error("Port $(port_path) not found")
  end
end


struct HookeanSpring <: StorageComponent
  k::Float64
end

AbstractSystems.interface(::HookeanSpring) = Interface(
  :q => Interface(PortType(displacement, true))
)

# function energy(c::HookeanSpring)
#   q = XVar(:q)
#   k = Const(c.k)
#   Const(0.5) * k * q * q
# end

function Base.get(spring::HookeanSpring, effort::EVar)
  (;box_path, port_path) = effort
  if port_path == DtryPath(:q)
    q = XVar(box_path, port_path)
    k = Const(spring.k)
    return k * q
  else
    error("Port $(port_path) not found")
  end
end


struct PointMass <: StorageComponent
  m::Float64
end

AbstractSystems.interface(::PointMass) = Interface(
  :p => Interface(PortType(momentum, true))
)

# function energy(c::PointMass)
#   p = XVar(:p)
#   m = Const(c.m)
#   Const(0.5) / m * p * p
# end

function Base.get(mass::PointMass, effort::EVar)
  (;box_path, port_path) = effort
  if port_path == DtryPath(:p)
    p = XVar(box_path, port_path)
    m = Const(mass.m)
    return p / m
  else
    error("Port $(port_path) not found")
  end
end


struct ThermalCapacity <: StorageComponent
  c₁::Float64
  c₂::Float64
end

AbstractSystems.interface(::ThermalCapacity) = Interface(
  :s => Interface(PortType(entropy, true))
)

# function energy(c::ThermalCapacity)
#   s = XVar(:s)
#   c₁ = Const(c.c₁)
#   c₂ = Const(c.c₂)
#   c₁ * exp(s / c₂)
# end

function Base.get(tc::ThermalCapacity, effort::EVar)
  (;box_path, port_path) = effort
  if port_path == DtryPath(:s)
    s = XVar(box_path, port_path)
    c₁ = Const(tc.c₁)
    c₂ = Const(tc.c₂)
    θ = c₁ / c₂ * exp(s / c₂)
    return θ - θ₀
  else
    error("Port $(port_path) not found")
  end
end

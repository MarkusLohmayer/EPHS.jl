
"""
    StoragePort(quantity::Quantity, effort::SymExpr)

A port of a [`StorageComponent`](@ref) provides the effort variable.

# Fields
- `quantity`: [`EPHS.AbstractSystems.Quantity`](@ref) of the port
- `effort`: [`EPHS.SymbolicExpressions.SymExpr`](@ref) defining the effort variable
"""
struct StoragePort
  quantity::Quantity
  effort::SymExpr
end


"""
    StorageComponent(ports::Dtry{StoragePort}, energy::SymExpr)

A `StorageComponent` is a primitive system representing energy storage.

# Fields
- `ports`: directory of [`StoragePort`](@ref)s
- `energy`: [`EPHS.SymbolicExpressions.SymExpr`](@ref) defining the energy

A `StorageComponent` should be constructed using the function
`StorageComponent(ports::Dtry{Quantity}, energy::SymExpr)`,
which uses symbolic differentiation
to compute the effort variables of the ports.
"""
struct StorageComponent <: Component
  ports::Dtry{StoragePort}
  energy::SymExpr

  # TODO Check that the only port variables appearing in `energy` are
  # XVars corresponding to the contents of `ports`.
  # Also, every port must have at least one corresponding state variable in `energy`.
end


"""
    StorageComponent(ports::Dtry{Quantity}, energy::SymExpr)

A `StorageComponent` is a primitive system representing energy storage.

# Arguments
- `ports`: directory of [`Quantity`](@ref)s defining the interface of the component (power ports only)
- `energy`: [`EPHS.SymbolicExpressions.SymExpr`](@ref) defining the energy
"""
function StorageComponent(ports::Dtry{Quantity}, energy::SymExpr)
  StorageComponent(
    mapwithpath(ports, StoragePort) do port_path, quantity
      x = XVar(DtryPath(), port_path)
      effort = diff(energy, x)
      if quantity == entropy
        effort = effort - θ₀
      elseif quantity == volume
        effort = effort + π₀
      end
      StoragePort(quantity, effort)
    end,
    energy
  )
end


function AbstractSystems.interface(sc::StorageComponent)
  map(sc.ports, PortType) do storage_port
    PortType(storage_port.quantity, true)
  end
end


AbstractSystems.fillcolor(::StorageComponent) = "#5082B0"


provides(sc::StorageComponent, xvar::XVar) =
  haspath(sc.ports, xvar.port_path)


provides(sc::StorageComponent, evar::EVar) =
  haspath(sc.ports, evar.port_path)


function provide(sc::StorageComponent, xvar::XVar)
  if haspath(sc.ports, xvar.port_path)
    return xvar
  end
  error("$(string(xvar)) not found")
end


function provide(sc::StorageComponent, evar::EVar)
  x = get(sc.ports, evar.port_path, nothing)
  if !isnothing(x)
    return x.effort
  end
  error("$(string(evar)) not found")
end


function Base.print(io::IO, sc::StorageComponent)
  println(io, "StorageComponent")
  print_dtry(io, sc.ports; print_value=print_port)
  print(io, "\nEnergy: ", string(sc.energy))
end


function print_port(io::IO, port::StoragePort; prefix::String)
  println(io, port.quantity)
  print(io, prefix, "e = ", port.effort)
end


AbstractSystems.total_energy(sc::StorageComponent; box_path::DtryPath=■) =
  isempty(box_path) ? sc.energy : replace(sc.energy, XVar) do xvar
    XVar(box_path, xvar.port_path)
  end


function AbstractSystems.total_entropy(sc::StorageComponent; box_path::DtryPath=■)
  expr = Const(0.0)
  foreach(sc.ports) do (port_path, port)
    if port.quantity == entropy
      expr = expr + XVar(box_path, port_path)
    end
  end
  expr
end

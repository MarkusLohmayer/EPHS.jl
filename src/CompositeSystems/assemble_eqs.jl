
function frompattern(fsys::FlatSystem, flow::FVar)
  (; box_path, port_path) = flow
  box = fsys.pattern.boxes[box_path]
  junction_path = box.ports[port_path].junction
  junction = fsys.pattern.junctions[junction_path]
  cs = fsys.connections[junction_path]
  internal = sum(
    -(fromcomponent(fsys, FVar(c.box_path, c.port_path)))
    for c in cs
    if c.power && (c.box_path != box_path || c.port_path != port_path)
  )
  if junction.exposed && junction.power
    return internal + FVar(■, junction_path)
  else
    return internal
  end
end


function frompattern(fsys::FlatSystem, effort::EVar)
  (; box_path, port_path) = effort
  box = fsys.pattern.boxes[box_path]
  junction_path = box.ports[port_path].junction
  cs = fsys.connections[junction_path]
  for c in cs
    if c.effort_provider
      evar = EVar(c.box_path, c.port_path)
      if c.storage
        return evar
      else
        return fromcomponent(fsys, evar)
      end
    end
  end
  junction = fsys.pattern.junctions[junction_path]
  if junction.exposed && junction.power
    return EVar(■, junction_path)
  end
  error(
    "port $(string(effort.port_path)) of box $(string(effort.box_path))" *
    " is not connected with a component providing an effort variable" *
    " and junction $(string(junction_path)) is also not exposed"
  )
end


function frompattern(fsys::FlatSystem, state::XVar)
  (; box_path, port_path) = state
  box = fsys.pattern.boxes[box_path]
  junction_path = box.ports[port_path].junction
  cs = fsys.connections[junction_path]
  for c in cs
    if c.state_provider
      return fromcomponent(fsys, XVar(c.box_path, c.port_path))
    end
  end
  junction = fsys.pattern.junctions[junction_path]
  if junction.exposed
    return XVar(■, junction_path)
  end
  error(
    "port $(string(state.port_path)) of box $(string(state.box_path))" *
    " is not connected with a component providing a state variable" *
    " and junction $(string(junction_path)) is also not exposed"
  )
end


function fromcomponent(fsys::FlatSystem, pvar::PortVar)
  box = fsys.pattern.boxes[pvar.box_path]
  fromcomponent(fsys, pvar, box.filling)
end


fromcomponent(fsys::FlatSystem, pvar::PowerVar, c::Component) =
  return map(provide(c, pvar), Union{PortVar,CVar}) do rhs_pvar
    if rhs_pvar isa PortVar
      frompattern(fsys, typeof(rhs_pvar)(pvar.box_path, rhs_pvar.port_path))
    else
      CVar(pvar.box_path, rhs_pvar.port_path)
    end
  end


fromcomponent(::FlatSystem, xvar::XVar, sc::StorageComponent) =
  provide(sc, xvar)


"""
Assemble evolution equations of a composite system
"""
function assemble(sys::CompositeSystem)
  fsys = FlatSystem(sys)
  assemble(fsys)
end


function assemble(fsys::FlatSystem)
  storages = Vector{DAEStorage}()
  constraints = Vector{DAEConstraint}()
  foreach(fsys.pattern.boxes) do (box_path, box)
    if box.filling isa StorageComponent
      foreach(box.filling.ports) do (port_path, port)
        xvar = XVar(box_path, port_path)
        quantity = port.quantity
        flow = frompattern(fsys, FVar(xvar))
        effort = fromcomponent(fsys, EVar(xvar), box.filling)
        push!(storages, DAEStorage(xvar, quantity, flow, effort))
      end
    elseif box.filling isa ReversibleComponent
      foreach(box.filling.ports) do (port_path, port)
        if port.variant isa Constraint
          cvar = CVar(box_path, port_path)
          residual = map(port.variant.residual, PortVar) do rhs_pvar
            frompattern(fsys, typeof(rhs_pvar)(box_path, rhs_pvar.port_path))
          end
          push!(constraints, DAEConstraint(cvar, residual))
        end
      end
    end
  end
  DAESystem(storages, constraints)
end

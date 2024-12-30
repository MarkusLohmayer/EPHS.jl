
function frompattern(fsys::FlatSystem, flow::FVar)
  (;box_path, port_path) = flow
  box, _ = fsys.pattern.boxes[box_path]
  junction_path = box.ports[port_path].junction
  junction, _ = fsys.pattern.junctions[junction_path]
  cs = fsys.connections[junction_path]
  # TODO Error if fromcomponent(...) returns nothing
  internal = -(sum(
    fromcomponent(fsys, FVar(c.box_path, c.port_path))
    for c in cs
    if c.power && (c.box_path != box_path || c.port_path != port_path)
  ))
  if junction.exposed && junction.power
    return internal + FVar(■, junction_path)
  else
    return internal
  end
end


function frompattern(fsys::FlatSystem, effort::EVar)
  (;box_path, port_path) = effort
  box, _ = fsys.pattern.boxes[box_path]
  junction_path = box.ports[port_path].junction
  cs = fsys.connections[junction_path]
  for c in cs
    if c.effort_provider
      return fromcomponent(fsys, EVar(c.box_path, c.port_path))
    end
  end
  junction, _ = fsys.pattern.junctions[junction_path]
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
  (;box_path, port_path) = state
  box, _ = fsys.pattern.boxes[box_path]
  junction_path = box.ports[port_path].junction
  cs = fsys.connections[junction_path]
  for c in cs
    if c.state_provider
      return fromcomponent(fsys, XVar(c.box_path, c.port_path))
    end
  end
  junction, _ = fsys.pattern.junctions[junction_path]
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
  resolve = pvar -> frompattern(fsys, pvar)
  box, _ = fsys.pattern.boxes[pvar.box_path]
  get(box.filling, pvar; resolve)
end


"""
Assemble evolution equations of a composite system
"""
function assemble(sys::CompositeSystem)
  fsys = FlatSystem(sys)
  assemble(fsys)
end


function assemble(fsys::FlatSystem)
  eqs = Eq[]
  foreach(fsys.pattern.boxes) do (box_path, (box, _))
    if box.filling isa StorageComponent
      foreachpath(box.ports) do port_path
        flow = FVar(box_path, port_path)
        eq = Eq(flow, frompattern(fsys, flow))
        push!(eqs, eq)
      end
    end
  end
  eqs
end

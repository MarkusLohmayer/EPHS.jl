
# For now assume that all ports are state ports and
# system is isolated (ignore exposed junctions)


function AbstractSystems.FVar(c::Connection)
  c.power && return FVar(c.box_path, c.port_path)
  error("connection is not a power port")
end


function AbstractSystems.EVar(c::Connection)
  c.power && return EVar(c.box_path, c.port_path)
  error("connection is not a power port")
end


"""
Other ports connected with the port
to which the given state variable belongs.
"""
function connected_ports(
  fsys::FlatSystem,
  xvar::XVar
)
  (;pattern, connections) = fsys
  (;box_path, port_path) = xvar
  box, _ = pattern.boxes[box_path]
  junction = box.ports[port_path].junction
  Iterators.filter(connections[junction]) do c
    !(c.box_path == box_path && c.port_path == port_path)
  end
end


"""
Other power ports connected with the power port
to which the given power variable belongs.
"""
function connected_power_ports(
  fsys::FlatSystem,
  pvar::PowerVar
)
  (;pattern, connections) = fsys
  (;box_path, port_path) = pvar
  box, _ = pattern.boxes[box_path]
  junction = box.ports[port_path].junction
  Iterators.filter(connections[junction]) do c
    c.power && !(c.box_path == box_path && c.port_path == port_path)
  end
end


function frompattern(fsys::FlatSystem, flow::FVar)
  -(sum(fromcomponent(fsys, FVar(c)) for c in connected_power_ports(fsys, flow)))
end


function frompattern(fsys::FlatSystem, effort::EVar)
  cs = connected_power_ports(fsys, effort)
  for c in cs
    if c.storage
      return fromcomponent(fsys, EVar(c))
    end
  end
  # make transformers work if there are no further connections
  cs = collect(cs)
  if length(cs) == 1
    return fromcomponent(fsys, EVar(first(cs)))
  end
  error(
    "port $(effort.port_path)) of box $(effort.box_path))" *
    " is not connected with a storage component" *
    " and there are more than one other connections, leaving me clueless"
  )
end


function fromcomponent(fsys::FlatSystem, pvar::PowerVar)
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

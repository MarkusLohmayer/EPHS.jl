
# For now assume that all ports are state ports and
# system is isolated (ignore exposed junctions)

export Connection, PreparedSystem
export connected_ports, connected_power_ports


"Data characterizing a port connected to some junction"
struct Connection
  box_path::DtryPath   # box to which the port belongs
  port_path::DtryPath  # name of the port
  power::Bool          # true means port is a power port
  storage::Bool        # true means box is filled by stroage component
end


function AbstractSystems.FVar(c::Connection)
  c.power && return FVar(c.box_path, c.port_path)
  error("connection is not a power port")
end


function AbstractSystems.EVar(c::Connection)
  c.power && return EVar(c.box_path, c.port_path)
  error("connection is not a power port")
end


struct PreparedSystem
  sys::CompositeSystem
  connections::Dtry{Vector{Connection}}

  """
  Prepare composite system for assembly of equations
  """
  function PreparedSystem(sys::CompositeSystem)
    # TODO Check that system is isolated
    connections = map(_ -> Vector{Connection}(), sys.pattern.junctions)
    foreach(sys.pattern.boxes) do (box_path, (box, _))
      # Check that all subsystems are primitive
      box.filling isa Component ||
        error("Subsystem $(box_path) is not a `Component`")
      # Identify `Connection`s at each junction
      storage = box.filling isa StorageComponent
      foreach(box.ports) do (port_path, (;junction, power))
        c = Connection(box_path, port_path, power, storage)
        push!(connections[junction], c)
      end
    end
    # Check that there is at most one storage component per junction
    foreach(connections) do (path, cs)
      mapreduce(c -> c.storage, +, cs) ≤ 1 ||
        error("More than one storage component at junction $path")
    end
    new(sys, connections)
  end
end


"""
Other ports connected with the port
to which the given state variable belongs.
"""
function connected_ports(
  psys::PreparedSystem,
  xvar::XVar
)
  (;sys, connections) = psys
  (;box_path, port_path) = xvar
  box, _ = sys.pattern.boxes[box_path]
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
  psys::PreparedSystem,
  pvar::PowerVar
)
  (;sys, connections) = psys
  (;box_path, port_path) = pvar
  box, _ = sys.pattern.boxes[box_path]
  junction = box.ports[port_path].junction
  Iterators.filter(connections[junction]) do c
    c.power && !(c.box_path == box_path && c.port_path == port_path)
  end
end


function frompattern(psys::PreparedSystem, flow::FVar)
  -(sum(fromcomponent(psys, FVar(c)) for c in connected_power_ports(psys, flow)))
end


function frompattern(psys::PreparedSystem, effort::EVar)
  cs = connected_power_ports(psys, effort)
  for c in cs
    if c.storage
      return fromcomponent(psys, EVar(c))
    end
  end
  # make transformers work if there are no further connections
  cs = collect(cs)
  if length(cs) == 1
    return fromcomponent(psys, EVar(first(cs)))
  end
  error(
    "port $(effort.port_path)) of box $(effort.box_path))" *
    " is not connected with a storage component" *
    " and there are more than one other connections, leaving me clueless"
  )
end


function fromcomponent(psys::PreparedSystem, pvar::PowerVar)
  box, _ = psys.sys.pattern.boxes[pvar.box_path]
  expr = get(box.filling, pvar)
  map(expr, PowerVar) do pvar
    frompattern(psys, pvar)
  end
end


"""
Assemble evolution equations of a composite system
"""
function assemble(sys::CompositeSystem)
  psys = PreparedSystem(sys)
  eqs = Eq[]
  foreach(psys.sys.pattern.boxes) do (box_path, (box, _))
    if box.filling isa StorageComponent
      foreachpath(box.ports) do port_path
        flow = FVar(box_path, port_path)
        eq = Eq(flow, frompattern(psys, flow))
        push!(eqs, eq)
      end
    end
  end
  eqs
end

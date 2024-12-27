
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

  # TODO Check that system is isolated
  """
  Prepare composite system for assembly of equations
  """
  function PreparedSystem(sys::CompositeSystem)
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
Other ports connected to the given `junction`,
besides the port identified by `box_path` and `port_path`
"""
function connected_ports(
  psys::PreparedSystem,
  box_path::DtryPath,
  port_path::DtryPath
)
  (;sys, connections) = psys
  box, _ = sys.pattern.boxes[box_path]
  junction = box.ports[port_path].junction
  Iterators.filter(connections[junction]) do c
    !(c.box_path == box_path && c.port_path == port_path)
  end
end


"""
Other power ports connected to the given `junction`,
besides the port identified by `box_path` and `port_path`
"""
function connected_power_ports(
  psys::PreparedSystem,
  box_path::DtryPath,
  port_path::DtryPath
)
  (;sys, connections) = psys
  box, _ = sys.pattern.boxes[box_path]
  junction = box.ports[port_path].junction
  Iterators.filter(connections[junction]) do c
    c.power && !(c.box_path == box_path && c.port_path == port_path)
  end
end


function Base.get(psys::PreparedSystem, flow::FVar)
  (;box_path, port_path) = flow
  cs = connected_power_ports(psys, box_path, port_path)
  -(sum(FVar(c) for c in cs))
end


function Base.get(psys::PreparedSystem, effort::EVar)
  (;box_path, port_path) = effort
  cs = connected_power_ports(psys, box_path, port_path)
  for c in cs
    if c.storage
      return EVar(c)
    end
  end
  # make transformers work if there are no further connections
  cs = collect(cs)
  if length(cs) == 1
    return EVar(first(cs))
  end
  error(
    "port $(string(port_path)) of box $(string(box_path))" *
    " is not connected with a storage component" *
    " and there are more than one other connections, leaving me clueless"
  )
end

# Resolving/eliminating power variables is done in a top-down approach
# A 'tracing approach' would probably be more efficient

function resolve(psys::PreparedSystem, x::PowerVar)
  while has_power_var(x)
    x = resolve_pattern(psys, x)
    x = resolve_component(psys, x)
  end
  x
end


function resolve_pattern(psys::PreparedSystem, expr::SymExpr)
  map(expr, PowerVar) do power_var
    get(psys, power_var)
  end
end


function resolve_component(psys::PreparedSystem, expr::SymExpr)
  map(expr, PowerVar) do power_var
    box, _ = psys.sys.pattern.boxes[power_var.box_path]
    get(box.filling, power_var)
  end
end


function has_power_var(expr::SymExpr)
  expr isa PowerVar && return true
  expr isa SymVar && return false
  if expr isa SymOp
    args = map(name -> getfield(expr, name), fieldnames(typeof(expr)))
    return any(has_power_var(arg) for arg in args)
  else
    error("shouldn't reach here")
  end
end


has_power_var(ss::Tuple{Vararg{SymExpr}}) = any(has_power_var(s) for s in ss)




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
        eq = Eq(flow, resolve(psys, flow))
        push!(eqs, eq)
      end
    end
  end
  eqs
end

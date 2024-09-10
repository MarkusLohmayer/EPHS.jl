
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


# Think about integrating connections into CompositeSystem itself
struct PreparedSystem{P<:Union{Nothing,Position}}
  sys::CompositeSystem{P}
  connections::Dtry{Vector{Connection}}

  """
  Check that all subsystems are primitive and
  identify `Connection`s at each junction.
  """
  function PreparedSystem{P}(sys::CompositeSystem) where {P}
    connections = map(_ -> Vector{Connection}(), sys.pattern.junctions)
    foreach(sys.pattern.boxes) do (box_path, (box, _))
      box.filling isa Component ||
        error("Subsystem $string(box_path) is not a `Component`")
      storage = box.filling isa StorageComponent
      foreach(box.ports) do (port_path, (;junction, power))
        c = Connection(box_path, port_path, power, storage)
        push!(connections[junction], c)
      end
    end
    # TODO check that there is (at most) one storage component per junction
    new{P}(sys, connections)
  end
end


function PreparedSystem(
  junctions::Dtry{Tuple{Junction,P}},
  boxes::Dtry{Tuple{InnerBox{AbstractSystem},P}}
) where {P}
  PreparedSystem{P}(CompositeSystem(junctions, boxes))
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
    c.box_path == box_path && c.port_path == port_path && return false
    true
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
    c.power || return false
    c.box_path == box_path && c.port_path == port_path && return false
    true
  end
end


function Base.get(psys::PreparedSystem, flow::FVar)
  (;box_path, port_path) = flow
  cs = connected_power_ports(psys, box_path, port_path)
  sum(
    -(FVar(c.box_path, c.port_path))
    for c in cs
  )
end


function Base.get(psys::PreparedSystem, effort::EVar)
  (;box_path, port_path) = effort
  cs = connected_power_ports(psys, box_path, port_path)
  for c in cs
    if c.storage
      return EVar(c.box_path, c.port_path)
    end
  end
  error(
    "port $(string(port_path)) of box $(string(box_path))" *
    "is not connected with a storage component"
  )
end


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
  (expr isa XVar || expr isa Const) && return false
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
function assemble(psys::PreparedSystem)
  sys = psys.sys
  eqs = Eq[]
  foreach(sys.pattern.boxes) do (box_path, (box, _))
    if box.filling isa StorageComponent
      foreach(box.ports) do (port_path, (;junction))
        flow = FVar(box_path, port_path)
        eq = Eq(flow, resolve(psys, flow))
        push!(eqs, eq)
      end
    end
  end
  eqs
end

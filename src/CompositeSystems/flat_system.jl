
"Connection of a port to a junction"
struct Connection
  box_path::DtryPath   # box to which the port belongs
  port_path::DtryPath  # name of the port
  power::Bool          # true means port is a power port
  storage::Bool        # true means box is filled by stroage component
end


function Pattern{Component,Nothing}(pattern::Pattern{AbstractSystem,P}) where {P}
  junctions = map(pattern.junctions, Tuple{Junction,Nothing}) do (junction, _)
    (junction, nothing)
  end
  boxes = mapwithpath(pattern.boxes, Tuple{InnerBox{Component},Nothing}) do box_path, (box, _)
    box.filling isa Component ||
      error("Subsystem $(box_path) is not a `Component`")
    (InnerBox{Component}(box.ports, box.filling), nothing)
  end
  Pattern{Component,Nothing}(junctions, boxes)
end


struct FlatSystem
  pattern::Pattern{Component,Nothing}
  connections::Dtry{Vector{Connection}}

  """
  Prepare composite system for assembly of equations
  """
  function FlatSystem(sys::CompositeSystem)
    # Reduce pattern
    pattern = Pattern{Component,Nothing}(sys.pattern)
    # TODO Check that system is isolated
    # Identify `Connection`s at each junction
    connections = map(_ -> Vector{Connection}(), pattern.junctions)
    foreach(pattern.boxes) do (box_path, (box, _))
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
    new(pattern, connections)
  end
end

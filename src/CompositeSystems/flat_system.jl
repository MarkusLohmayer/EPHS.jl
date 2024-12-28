
"Connection of a port to a junction"
struct Connection
  box_path::DtryPath   # box to which the port belongs
  port_path::DtryPath  # name of the port
  power::Bool          # true means port is a power port
  storage::Bool        # true means box is filled by stroage component
end


function Pattern{Component,Nothing}(pattern::Pattern{AbstractSystem,P}) where {P}
  junctions = merge(
    map(pattern.junctions, Tuple{Junction,Nothing}) do (junction, _)
      (junction, nothing)
    end,
    map(pattern.boxes, Dtry{Tuple{Junction,Nothing}}) do (box, _)
      if box.filling isa Component
        Dtry{Tuple{Junction,Nothing}}()
      elseif box.filling isa CompositeSystem
        filling = box.filling.pattern
        filtermap(filling.junctions, Tuple{Junction,Nothing}) do (junction, _)
          junction.exposed ? nothing : Some((junction, nothing))
        end
      else
        error("should not reach here")
      end
    end |> flatten
  )
  boxes = mapwithpath(
    pattern.boxes,
    Dtry{Tuple{InnerBox{Component},Nothing}}
  ) do box_path, (box, _)
    if box.filling isa Component
      Dtry{Tuple{InnerBox{Component},Nothing}}(
        (InnerBox{Component}(box.ports, box.filling), nothing)
      )
    elseif box.filling isa CompositeSystem
      filling = box.filling.pattern
      map(filling.boxes, Tuple{InnerBox{Component},Nothing}) do (inner_box, _)
        ports = map(inner_box.ports, InnerPort) do port
          junction_path = port.junction
          junction, _ = filling.junctions[junction_path]
          if junction.exposed
            InnerPort(box.ports[junction_path].junction, port.power)
          else
            InnerPort(box_path * junction_path, port.power)
          end
        end
        (InnerBox{Component}(ports, inner_box.filling), nothing)
      end
    else
      error("should not reach here")
    end
  end |> flatten
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


function Base.show(io::IO, ::MIME"text/plain", fsys::FlatSystem)
  println(io, "Junctions:")
  print_dtry(io, fsys.pattern.junctions; print_value=Patterns.print_junction)
  println(io, "\nBoxes:")
  print_dtry(io, fsys.pattern.boxes; print_value=print_box)
end


function print_box(io::IO, t::Tuple{InnerBox{Component},Nothing}, prefix::String)
  box, _ = t
  println(io, typeof(box.filling))
  print(io, prefix)
  print_dtry(io, box.ports; prefix, print_value=Patterns.print_port)
end

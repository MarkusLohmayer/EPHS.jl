
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


"Connection of an `InnerPort` to a `Junction`"
struct Connection
  box_path::DtryPath      # box to which the port belongs
  port_path::DtryPath     # name of the port
  power::Bool             # true means port is a power port
  effort_provider::Bool   # true means port provides effort variable
  state_provider::Bool    # true means port provides state variable
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
    # Identify `Connection`s at each junction
    connections = map(_ -> Vector{Connection}(), pattern.junctions)
    foreach(pattern.boxes) do (box_path, (box, _))
      storage = box.filling isa StorageComponent
      foreach(box.ports) do (port_path, (;junction, power))
        effort_provider = storage || !isnothing(get(box.filling, EVar(DtryPath(), port_path)))
        state_provider = storage || !isnothing(get(box.filling, XVar(DtryPath(), port_path)))
        c = Connection(box_path, port_path, power, effort_provider, state_provider)
        push!(connections[junction], c)
      end
    end
    # Check that there is at most one effort and state provider per junction
    foreach(connections) do (junction_path, cs)
      effort_providers::Int = mapreduce(c -> c.effort_provider, +, cs)
      effort_providers ≤ 1 || error(
        "At junction $(string(junction_path)) there are" *
        " $(effort_providers) connections that provide an effort variable"
      )
      state_providers::Int = mapreduce(c -> c.state_provider, +, cs)
      state_providers ≤ 1 || error(
        "At junction $(string(junction_path)) there are" *
        " $(state_providers) connections that provide a state variable"
      )
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


MoreBase.flatten(component::Component) = component


function MoreBase.flatten(sys::CompositeSystem{F,P}) where {F,P}
  sys.isflat && return sys
  # Recursively flatten subsystems
  boxes_flat = map(sys.pattern.boxes, InnerBox{F,Nothing}) do box
    InnerBox{F,Nothing}(box.ports, flatten(box.filling), nothing)
  end
  # Flatten top level
  junctions = merge(
    map(sys.pattern.junctions, Junction{Nothing}) do junction
      Junction{Nothing}(junction.exposed, junction.quantity, junction.power, nothing)
    end,
    map(boxes_flat, Dtry{Junction{Nothing}}) do box
      if box.filling isa Component
        Dtry{Junction{Nothing}}()
      elseif box.filling isa CompositeSystem
        filling = box.filling.pattern
        filtermap(filling.junctions, Junction{Nothing}) do junction
          junction.exposed ? nothing : Some(
            Junction{Nothing}(false, junction.quantity, junction.power, nothing)
          )
        end
      else
        error("should not reach here")
      end
    end |> flatten
  )
  boxes = mapwithpath(boxes_flat, Dtry{InnerBox{F,Nothing}}) do box_path, box
    if box.filling isa Component
      Dtry{InnerBox{F,Nothing}}(
        InnerBox{F,Nothing}(box.ports, box.filling, nothing)
      )
    elseif box.filling isa CompositeSystem
      filling = box.filling.pattern
      map(filling.boxes, InnerBox{F,Nothing}) do inner_box
        ports = map(inner_box.ports, InnerPort) do port
          junction_path = port.junction
          junction = filling.junctions[junction_path]
          if junction.exposed
            InnerPort(box.ports[junction_path].junction, port.power)
          else
            InnerPort(box_path * junction_path, port.power)
          end
        end
        InnerBox{F,Nothing}(ports, inner_box.filling, nothing)
      end
    else
      error("should not reach here")
    end
  end |> flatten
  CompositeSystem{F,Nothing}(
    Pattern{F,Nothing}(junctions, boxes; check=false);
    check=false
  )
end


"Connection of an `InnerPort` to a `Junction`"
struct Connection
  box_path::DtryPath      # box to which the port belongs
  port_path::DtryPath     # name of the port
  power::Bool             # true means port is a power port
  effort_provider::Bool   # true means port provides effort variable
  state_provider::Bool    # true means port provides state variable
end


struct FlatSystem{F<:AbstractSystem}
  pattern::Pattern{F,P} where {P}
  connections::Dtry{Vector{Connection}}

  """
  Prepare `CompositeSystem` for assembly of equations
  """
  function FlatSystem(
    sys::CompositeSystem{F,P}
  ) where {F<:AbstractSystem,P<:Union{Nothing,Position}}
    # Flatten system
    sys_flat = flatten(sys)
    # Identify `Connection`s at each junction
    connections = map(_ -> Vector{Connection}(), sys_flat.pattern.junctions)
    foreach(sys_flat.pattern.boxes) do (box_path, box)
      storage = box.filling isa StorageComponent
      foreach(box.ports) do (port_path, (; junction, power))
        effort_provider = storage || provides(box.filling, EVar(DtryPath(), port_path))
        state_provider = storage || provides(box.filling, XVar(DtryPath(), port_path))
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
    new{F}(sys_flat.pattern, connections)
  end
end


Base.show(io::IO, ::MIME"text/plain", fsys::FlatSystem) =
  print(io, fsys.pattern)

Base.print(io::IO, fsys::FlatSystem) =
  print(io, fsys.pattern)

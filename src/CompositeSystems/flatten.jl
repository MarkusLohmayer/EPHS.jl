
MoreBase.flatten(component::Component) = component


function MoreBase.flatten(sys::CompositeSystem{P}) where {P}
  sys.isflat && return sys
  # Recursively flatten subsystems
  boxes_flat = map(sys.pattern.boxes, InnerBox{AbstractSystem,Nothing}) do box
    InnerBox{AbstractSystem,Nothing}(box.ports, flatten(box.filling), nothing)
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
  boxes = mapwithpath(boxes_flat, Dtry{InnerBox{AbstractSystem,Nothing}}) do box_path, box
    if box.filling isa Component
      Dtry{InnerBox{AbstractSystem,Nothing}}(
        InnerBox{AbstractSystem,Nothing}(box.ports, box.filling, nothing)
      )
    elseif box.filling isa CompositeSystem
      filling = box.filling.pattern
      map(filling.boxes, InnerBox{AbstractSystem,Nothing}) do inner_box
        ports = map(inner_box.ports, InnerPort) do port
          junction_path = port.junction
          junction = filling.junctions[junction_path]
          if junction.exposed
            InnerPort(box.ports[junction_path].junction, port.power)
          else
            InnerPort(box_path * junction_path, port.power)
          end
        end
        InnerBox{AbstractSystem,Nothing}(ports, inner_box.filling, nothing)
      end
    else
      error("should not reach here")
    end
  end |> flatten
  CompositeSystem{Nothing}(
    Pattern{AbstractSystem,Nothing}(junctions, boxes; check=false);
    check=false
  )
end

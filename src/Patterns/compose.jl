
# For the moment, this is primarily an academic exercise
# to convince ourselves that the EPHS syntax
# (i.e. `Interface`s as objects and `Pattern{Nothing,Nothing}`s as morphisms)
# form a `Dtry`-multicategory.


"""
    identity(x::Interface) -> Pattern{Nothing,Nothing}

Return the identity pattern on the given interface.
"""
function Base.identity(interface::Interface)
  junctions = map(interface, Junction{Nothing}) do port_type
    Junction{Nothing}(true, port_type.quantity, port_type.power, nothing)
  end
  boxes = Dtry{InnerBox{Nothing,Nothing}}(
    InnerBox{Nothing,Nothing}(
      mapwithpath(interface, InnerPort) do port_path, port_type
        InnerPort(port_path, port_type.power)
      end,
      nothing,
      nothing
    )
  )
  Pattern{Nothing,Nothing}(junctions, boxes; check=false)
end


"""
    compose(pattern::Pattern{Nothing,Nothing}, fillings::Dtry{Pattern{Nothing,Nothing}}) -> Pattern{Nothing,Nothing}

Composition operation for the Dtry-multicategory of patterns.
"""
function compose(
  pattern::Pattern{Nothing,Nothing},
  fillings::Dtry{Pattern{Nothing,Nothing}}
)
  boxes = _boxes(pattern, fillings)
  junctions = _junctions(pattern, fillings)
  Pattern{Nothing,Nothing}(junctions, boxes; check=false)
end


function _junctions(
  pattern::Pattern{Nothing,Nothing},
  fillings::Dtry{Pattern{Nothing,Nothing}}
)
  # Merge top-level junctions (from `pattern`)
  # with those junctions of the subsystems (`fillings`)
  # that are not exposed
  merge(
    pattern.junctions,
    # Flatten directory of directory of (unexposed) junctions (from `fillings`)
    map(fillings, Dtry{Junction{Nothing}}) do filling
      filter(filling.junctions) do junction
        !(junction.exposed)
      end
    end |> flatten
  )
end


function _boxes(
  pattern::Pattern{Nothing,Nothing},
  fillings::Dtry{Pattern{Nothing,Nothing}}
)
  # Flatten directory of directories of boxes (from `fillings`)
  zipmapwithpath(
    pattern.boxes,
    fillings,
    Dtry{InnerBox{Nothing,Nothing}}
  ) do box_path, box, filling
    # Check if composable
    interface(pattern, box_path) == interface(filling) ||
      error("interface for box $(string(box_path)) does not match")
    # Reassign ports to junctions (endomorphism)
    map(filling.boxes, InnerBox{Nothing,Nothing}) do inner_box
      ports = map(inner_box.ports, InnerPort) do port
        junction_path = port.junction
        junction = filling.junctions[junction_path]
        if junction.exposed
          InnerPort(box.ports[junction_path].junction, port.power)
        else
          InnerPort(box_path * junction_path, port.power)
        end
      end
      InnerBox{Nothing,Nothing}(ports, nothing, nothing)
    end
  end |> flatten
end

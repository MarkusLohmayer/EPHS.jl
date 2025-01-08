module Patterns

export Position, Junction, InnerPort, InnerBox
export Pattern
export compose
export print_svg


using ..MoreBase
using ..Directories
using ..AbstractSystems


struct Position
  r::Int
  c::Int
end


struct Junction{P<:Union{Nothing,Position}}
  exposed::Bool
  quantity::Quantity
  power::Bool # relevant only if exposed == true
  position::P
end


struct InnerPort
  junction::DtryPath
  power::Bool
end


struct InnerBox{F<:Union{Nothing,AbstractSystem},P<:Union{Nothing,Position}}
  ports::Dtry{InnerPort}
  filling::F
  position::P
end


struct Pattern{F<:Union{Nothing,AbstractSystem},P<:Union{Nothing,Position}}
  junctions::Dtry{Junction{P}}
  boxes::Dtry{InnerBox{F,P}}

  function Pattern{F,P}(
    junctions::Dtry{Junction{P}},
    boxes::Dtry{InnerBox{F,P}};
    check::Bool=true
  ) where {F<:Union{Nothing,AbstractSystem},P<:Union{Nothing,Position}}
    if check
      # Check that ports are assigned to junctions that exist
      # Check that every junction has at least one connected InnerPort
      junction_paths = Set{DtryPath}()
      foreachpath(junctions) do junction_path
        push!(junction_paths, junction_path)
      end
      foreach(boxes) do (box_path, box)
        foreach(box.ports) do (port_path, port)
          haskey(junctions, port.junction) ||
            error(
              "Port $(string(port_path)) of box $(string(box_path))" *
              " is connected to undefined junction $(string(port.junction))"
            )
          delete!(junction_paths, port.junction)
        end
      end
      isempty(junction_paths) ||
        error(
          "The following junctions have no connected `InnerPort`s: " *
          join((string(path) for path in junction_paths), ", ")
        )
    end
    new{F,P}(junctions, boxes)
  end
end


Junction(exposed::Bool, quantity::Quantity, power::Bool, position::Position) =
  Junction{Position}(exposed, quantity, power, position)

Junction(exposed::Bool, quantity::Quantity, power::Bool) =
  Junction{Nothing}(exposed, quantity, power, nothing)

Junction(exposed::Bool, quantity::Quantity, position::Position) =
  Junction{Position}(exposed, quantity, true, position)

Junction(exposed::Bool, quantity::Quantity) =
  Junction{Nothing}(exposed, quantity, true, nothing)

Junction(quantity::Quantity, power::Bool, position::Position) =
  Junction{Position}(false, quantity, power, position)

Junction(quantity::Quantity, power::Bool) =
  Junction{Nothing}(false, quantity, power, nothing)

Junction(quantity::Quantity, position::Position) =
  Junction{Position}(false, quantity, true, position)

Junction(quantity::Quantity) =
  Junction{Nothing}(false, quantity, true, nothing)


InnerPort(junction::DtryPath) = InnerPort(junction, true)


InnerBox(ports::Dtry{InnerPort}, filling::AbstractSystem, position::Position) =
  InnerBox{AbstractSystem,Position}(ports, filling, position)

InnerBox(ports::Dtry{InnerPort}, filling::AbstractSystem) =
  InnerBox{AbstractSystem,Nothing}(ports, filling, nothing)

InnerBox(ports::Dtry{InnerPort}, position::Position) =
  InnerBox{Nothing,Position}(ports, nothing, position)

InnerBox(ports::Dtry{InnerPort}) =
  InnerBox{Nothing,Nothing}(ports, nothing, nothing)


Pattern(
  junctions::Dtry{Junction{P}},
  boxes::Dtry{InnerBox{F,P}};
  check::Bool=true
) where {F<:Union{Nothing,AbstractSystem},P<:Union{Nothing,Position}} =
  Pattern{F,P}(junctions, boxes; check)


"""
Reduce a `Pattern{F,P}` to a `Pattern{Nothing,Nothing}` by forgetting
the filling of boxes as well as the positions of junctions and boxes
"""
function Pattern{Nothing,Nothing}(pattern::Pattern{F,P}) where {F,P}
  junctions = map(pattern.junctions, Junction{Nothing}) do junction
    Junction{Nothing}(junction.exposed, junction.quantity, junction.power, nothing)
  end
  boxes = map(pattern.boxes, InnerBox{Nothing,Nothing}) do box
    InnerBox{Nothing,Nothing}(box.ports, nothing, nothing)
  end
  Pattern{Nothing,Nothing}(junctions, boxes; check=false)
end


# get interfaces of outer box and inner boxes
include("interfaces.jl")

# composition (hierarchical nesting) of patterns
include("compose.jl")

# show patterns as SVG or text
include("show_svg.jl")
include("show_text.jl")

end

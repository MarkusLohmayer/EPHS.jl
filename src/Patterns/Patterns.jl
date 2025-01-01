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
      # Check if ports are assigned to junctions that exist
      foreachvalue(boxes) do box
        foreachvalue(box.ports) do port
          haskey(junctions, port.junction) ||
            error("junction $(string(port.junction)) not found")
        end
      end
    end
    new{F,P}(junctions, boxes)
  end
end


Junction(exposed::Bool, quantity::Quantity, power::Bool) =
  Junction{Nothing}(exposed, quantity, power, nothing)


Junction(exposed::Bool, quantity::Quantity, power::Bool, position::Position) =
  Junction{Position}(exposed, quantity, power, position)


InnerBox(ports::Dtry{InnerPort}) =
  InnerBox{Nothing,Nothing}(ports, nothing, nothing)


InnerBox(ports::Dtry{InnerPort}, filling::AbstractSystem) =
  InnerBox{AbstractSystem,Nothing}(ports, filling, nothing)


InnerBox(ports::Dtry{InnerPort}, position::Position) =
  InnerBox{Nothing,Position}(ports, nothing, position)


InnerBox(ports::Dtry{InnerPort}, filling::AbstractSystem, position::Position) =
  InnerBox{AbstractSystem,Position}(ports, filling, position)


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

# macro to define patterns in a more concise manner
# include("macro.jl")

end

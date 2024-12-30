module Patterns

export Junction, InnerPort, InnerBox, Position
export Pattern
export compose
export print_svg


using ..MoreBase
using ..Directories
using ..AbstractSystems


struct Junction
  exposed::Bool
  quantity::Quantity
  power::Bool # relevant only if exposed == true
end


struct InnerPort
  junction::DtryPath
  power::Bool
end


struct InnerBox{F<:Union{Nothing,AbstractSystem}}
  ports::Dtry{InnerPort}
  filling::F
end


struct Position
  r::Int
  c::Int
end


struct Pattern{F<:Union{Nothing,AbstractSystem},P<:Union{Nothing,Position}}
  junctions::Dtry{Tuple{Junction,P}}
  boxes::Dtry{Tuple{InnerBox{F},P}}

  function Pattern{F,P}(
    junctions::Dtry{Tuple{Junction,P}},
    boxes::Dtry{Tuple{InnerBox{F},P}};
    check::Bool=true
  ) where {F<:Union{Nothing,AbstractSystem},P<:Union{Nothing,Position}}
    if check
      # Check if ports are assigned to junctions that exist
      foreachvalue(boxes) do (box, _)
        foreachvalue(box.ports) do port
          haskey(junctions, port.junction) ||
            error("junction $(string(port.junction)) not found")
        end
      end
    end
    new{F,P}(junctions, boxes)
  end
end


"""
Reduce a `Pattern{F,P}` to a `Pattern{Nothing,Nothing}` by forgetting
the filling of boxes as well as the positions of junctions and boxes
"""
function Pattern{Nothing,Nothing}(pattern::Pattern{F,P}) where {F,P}
  junctions = map(pattern.junctions, Tuple{Junction,Nothing}) do (junction, _)
    (junction, nothing)
  end
  boxes = map(pattern.boxes, Tuple{InnerBox{Nothing},Nothing}) do (box, _)
    (InnerBox{Nothing}(box.ports, nothing), nothing)
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

module Patterns

export Junction, InnerPort, InnerBox, Position
export Pattern
export print_svg

# macro
# export @pattern


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

  function Pattern{F,P}(junctions, boxes) where {F,P}
    if !isempty(boxes)
      nonempty_boxes = nothing_or_nonempty(boxes)
      foreachvalue(nonempty_boxes) do (box, _)
        if !isempty(box.ports)
          ports = nothing_or_nonempty(box.ports)
          foreachvalue(ports) do port
            haskey(junctions, port.junction) ||
              error("junction $(string(port.junction)) not found")
          end
        end
      end
    end
    new{F,P}(junctions, boxes)
  end
end


# include("access.jl")

# get interfaces of outer box and inner boxes
include("interfaces.jl")

# composition (hierarchical nesting) of patterns
include("compose.jl")

# show pattern as SVG
include("show.jl")

# macro to define patterns in a more concise manner
# include("macro.jl")

end

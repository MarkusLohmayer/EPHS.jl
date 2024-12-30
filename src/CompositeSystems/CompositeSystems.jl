module CompositeSystems

export CompositeSystem
export FlatSystem
export assemble


using ..MoreBase
using ..Directories
using ..SymbolicExpressions
using ..AbstractSystems
using ..Patterns
using ..Components


"""
A composite system is a pattern,
where each inner box is filled by a subsystem.
"""
struct CompositeSystem{F<:AbstractSystem,P<:Union{Nothing,Position}} <: AbstractSystem
  pattern::Pattern{F,P}

  function CompositeSystem{F,P}(
    pattern::Pattern{F,P}
  ) where {F<:AbstractSystem,P<:Union{Nothing,Position}}
    # Check if interfaces of subsystems match
    foreach(pattern.boxes) do (box_path, (box, _))
      interface(pattern, box_path) == interface(box.filling) ||
        error("Interface of box $box_path does not match the interface of its filling")
    end
    new{F,P}(pattern)
  end
end


function CompositeSystem(
  junctions::Dtry{Tuple{Junction,P}},
  boxes::Dtry{Tuple{InnerBox{F},P}}
) where {F<:AbstractSystem,P<:Union{Nothing,Position}}
  CompositeSystem{F,P}(Pattern{F,P}(junctions, boxes))
end


AbstractSystems.interface(sys::CompositeSystem) = interface(sys.pattern)
AbstractSystems.fillcolor(::CompositeSystem) = "#FFE381"


Base.show(io::IO, ::MIME"image/svg+xml", sys::CompositeSystem{F,Position}) where {F} =
  show(io, MIME"image/svg+xml"(), sys.pattern)

Base.show(io::IO, ::MIME"text/plain", sys::CompositeSystem{F,Nothing}) where {F} =
  print(io, sys)

Base.print(io::IO, sys::CompositeSystem{F,P}) where {F,P} =
  print(io, sys.pattern)


# Assembly of equations
include("flat_system.jl")
include("assemble_eqs.jl")

end

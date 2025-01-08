module CompositeSystems

export CompositeSystem
export FlatSystem
export DAESystem
export equations
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
struct CompositeSystem{P<:Union{Nothing,Position}} <: AbstractSystem
  pattern::Pattern{AbstractSystem,P}
  isflat::Bool

  function CompositeSystem{P}(
    pattern::Pattern{AbstractSystem,P};
    check::Bool=true
  ) where {P<:Union{Nothing,Position}}
    if check
      # Check if interfaces of subsystems match
      foreach(pattern.boxes) do (box_path, box)
        interface(pattern, box_path) == interface(box.filling) ||
          error("Interface of box $(string(box_path)) does not match the interface of its filling")
      end
    end
    isflat = all(box -> box.filling isa Component, pattern.boxes)
    new{P}(pattern, isflat)
  end
end


function CompositeSystem(
  junctions::Dtry{Junction{P}},
  boxes::Dtry{InnerBox{AbstractSystem,P}}
) where {P<:Union{Nothing,Position}}
  CompositeSystem{P}(Pattern{AbstractSystem,P}(junctions, boxes))
end


AbstractSystems.interface(sys::CompositeSystem) = interface(sys.pattern)


AbstractSystems.fillcolor(::CompositeSystem) = "#FFE381"


Base.show(io::IO, ::MIME"image/svg+xml", sys::CompositeSystem{Position}) =
  show(io, MIME"image/svg+xml"(), sys.pattern)

Base.show(io::IO, ::MIME"text/plain", sys::CompositeSystem{Nothing}) =
  print(io, sys)

Base.print(io::IO, sys::CompositeSystem) =
  print(io, sys.pattern)


# Flatten hierarchically nested composite systems
include("flatten.jl")

# Assembly of equations
include("flat_system.jl")
include("dae_system.jl")
include("assemble_eqs.jl")

end

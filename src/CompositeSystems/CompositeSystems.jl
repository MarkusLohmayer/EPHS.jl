module CompositeSystems

export CompositeSystem
export assemble

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

  function CompositeSystem{P}(
    pattern::Pattern{AbstractSystem,P}
  ) where {P<:Union{Nothing,Position}}
    # Check if interfaces of subsystems match
    foreach(pattern.boxes) do (name, (box, _))
      interface(pattern, name) == interface(box.filling)  ||
        error("Interface of box $string(name) does not match the interface of its filling")
    end
    new{P}(pattern)
  end
end


function CompositeSystem(
  junctions::Dtry{Tuple{Junction,P}},
  boxes::Dtry{Tuple{InnerBox{AbstractSystem},P}}
) where {P}
  CompositeSystem{P}(Pattern{AbstractSystem,P}(junctions, boxes))
end


function Base.show(io::IO, ::MIME"image/svg+xml", sys::CompositeSystem{Position})
  print(io, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
  print_svg(io, sys.pattern)
end


include("assemble_eqs.jl")


end

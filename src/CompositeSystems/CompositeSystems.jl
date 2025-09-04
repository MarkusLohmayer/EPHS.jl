"""
The `CompositeSystems` module defines
[`CompositeSystem`](@ref)s
and provides the means to assemble them into
systems of differential(-algebraic) equations,
see [`DAESystem`](@ref) and [`assemble`](@ref).
"""
module CompositeSystems

export CompositeSystem
export subsystem
export DAESystem
export equations
export assemble
export update_parameters


using ..MoreBase
using ..Directories
using ..SymbolicExpressions
using ..AbstractSystems
using ..Patterns
using ..Components


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


"""
    CompositeSystem(junctions::Dtry{Junction{P}}, boxes::Dtry{InnerBox{AbstractSystem,P}}) where {P<:Union{Nothing,Position}}

A `CompositeSystem` is given by a [`Pattern`](@ref),
where each [`InnerBox`](@ref) is filled by
a system whose interface matches that of the box.
"""
function CompositeSystem(
  junctions::Dtry{Junction{P}},
  boxes::Dtry{InnerBox{AbstractSystem,P}}
) where {P<:Union{Nothing,Position}}
  CompositeSystem{P}(Pattern{AbstractSystem,P}(junctions, boxes))
end


"""
    CompositeSystem{Nothing}(sys::CompositeSystem{Position})

Reduce a `CompsiteSystem{Position}` to a `CompositeSystem{Nothing}`
by forgetting the the positions of junctions and boxes.
"""
function CompositeSystem{Nothing}(sys::CompositeSystem{Position})
  junctions = map(sys.pattern.junctions, Junction{Nothing}) do junction
    Junction{Nothing}(junction.quantity, nothing, junction.exposed, junction.power)
  end
  boxes = map(sys.pattern.boxes, InnerBox{AbstractSystem,Nothing}) do box
    InnerBox{AbstractSystem,Nothing}(box.ports, box.filling, nothing)
  end
  pattern = Pattern{AbstractSystem,Nothing}(junctions, boxes; check=false)
  CompositeSystem{Nothing}(pattern)
end


AbstractSystems.interface(sys::CompositeSystem) = interface(sys.pattern)


AbstractSystems.fillcolor(::CompositeSystem) = "#FFE381"


Base.show(io::IO, ::MIME"image/svg+xml", sys::CompositeSystem{Position}) =
  show(io, MIME"image/svg+xml"(), sys.pattern)

Base.show(io::IO, ::MIME"text/plain", sys::CompositeSystem{Nothing}) =
  print(io, sys)

Base.print(io::IO, sys::CompositeSystem) =
  print(io, sys.pattern)


subsystem(sys::CompositeSystem, box_path::DtryPath) =
  sys.pattern.boxes[box_path].filling


function AbstractSystems.total_energy(sys::CompositeSystem; box_path::DtryPath=■)
  expr = Const(0)
  foreach(sys.pattern.boxes) do (inner_box_path, box)
    expr = expr + total_energy(box.filling; box_path=box_path * inner_box_path)
  end
  expr
end


function AbstractSystems.total_entropy(sys::CompositeSystem; box_path::DtryPath=■)
  expr = Const(0)
  foreach(sys.pattern.boxes) do (inner_box_path, box)
    expr = expr + total_entropy(box.filling; box_path=box_path * inner_box_path)
  end
  expr
end


# Flatten hierarchically nested composite systems
include("flatten.jl")

# Assembly of equations (flatten then interconnect primitive subsystems)
include("flat_system.jl")
include("frompattern.jl")
include("fromcomponent.jl")
include("dae_system.jl")
include("assemble.jl")

# Semantics of composite systems ((recursively) interconnect subsystems)
include("relation.jl")

end

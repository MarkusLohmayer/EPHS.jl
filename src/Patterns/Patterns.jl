"""
The `Patterns` module defines
interconnection [`Pattern`](@ref)s,
which provide a graphical syntax
for expressing a power-preserving interconnection of
finitely many subsystems into a single composite system.
Since subsystems may again have yet simpler subsystems,
patterns can be composed, i.e. hierarchically nested.
Whenever the outer interface of a pattern
matches a subsystem interface of another pattern,
the patterns can be composed.
"""
module Patterns

export Position, Junction, InnerPort, InnerBox
export Pattern
export compose
export print_svg


using ..MoreBase
using ..Directories
using ..AbstractSystems


"""
    Position(r::Int, c::Int)

Position of a [`Junction`](@ref) or [`InnerBox`](@ref)
used to graphically represent a [`Pattern`](@ref).

# Fields
- `r`: row index on grid
- `c`: column index on grid
"""
struct Position
  r::Int
  c::Int
end


const Doc_Junction = """
A junction represents an energy domain,
where the connected ports may exchange
information about the state of the given `quantity`
and where the connected power ports may additionally exchange
energy by exchanging the given `quantity`.
If `exposed=true` an outer port is added,
which is a power port if `power=true`.
"""


"""
    Junction{P}(quantity::Quantity, position::P, exposed::Bool, power::Bool) where {P<:Union{Nothing,Position}}

$(Doc_Junction)

# Fields
- `quantity`: associated [`Quantity`](@ref)
- `position`: `nothing` or a grid [`Position`](@ref)
- `exposed`: true means the junction has a connected outer port
- `power`: if `exposed`, determines if the outer port is a power port
"""
struct Junction{P<:Union{Nothing,Position}}
  quantity::Quantity
  position::P
  exposed::Bool # (at most one) outer port (per junction)
  power::Bool # relevant only if exposed
end


"""
    Junction(quantity::Quantity, position::Position; exposed::Bool=false, power::Bool=true)

$(Doc_Junction)
"""
Junction(
  quantity::Quantity,
  position::Position;
  exposed::Bool=false,
  power::Bool=true
) = Junction{Position}(quantity, position, exposed, power)


"""
    Junction(quantity::Quantity; exposed::Bool=false, power::Bool=true)

$(Doc_Junction)
"""
Junction(
  quantity::Quantity;
  exposed::Bool=false,
  power::Bool=true
) = Junction{Nothing}(quantity, nothing, exposed, power)


const Doc_InnerPort = """
An `InnerPort` is a port of an [`InnerBox`](@ref),
which is connected to the [`Junction`](@ref)
with the given [`DtryPath`](@ref)
in the directory of junctions, see [`Pattern`](@ref).
If `power=false` the port is a state port,
which may exchange information about
the state of the quantity associated to the junction.
If `power=true` the port is a power port,
which may additionally exchange energy
by exchanging the associated quantity.
"""


"""
    InnerPort(junction::DtryPath, power::Bool)

$(Doc_InnerPort)

# Fields
- `junction`: [`DtryPath`](@ref) to the assigned junction
- `power`: `false` means state port, `true` means power port
"""
struct InnerPort
  junction::DtryPath
  power::Bool
end


"""
    InnerPort(junction::DtryPath; power::Bool=true)

$(Doc_InnerPort)
"""
InnerPort(junction::DtryPath; power::Bool=true) =
  InnerPort(junction, power)


const Doc_InnerBox = """
An `InnerBox` represents a subsystem,
whose [`Interface`](@ref) is given
as a directory of ports, see [`InnerPort`](@ref).
"""


const Doc_InnerBox_Filling = """
To define systems hierarchically,
a `filling` is assigned,
which is a system whose interface matches that of the box.
"""


"""
    InnerBox(ports::Dtry{InnerPort}, filling::F, position::P) where {{F<:Union{Nothing,AbstractSystem},P<:Union{Nothing,Position}}

$(Doc_InnerBox)
$(Doc_InnerBox_Filling)

# Fields
- `ports`: directory of ports defining the [`Interface`](@ref) of the box
- `filling`: `nothing` or an [`AbstractSystem`](@ref) filling the box
- `position`: `nothing` or a grid [`Position`](@ref)
"""
struct InnerBox{F<:Union{Nothing,AbstractSystem},P<:Union{Nothing,Position}}
  ports::Dtry{InnerPort}
  filling::F
  position::P
end


"""
    InnerBox(ports::Dtry{InnerPort}, filling::AbstractSystem, position::Position)

$(Doc_InnerBox)
$(Doc_InnerBox_Filling)
"""
InnerBox(ports::Dtry{InnerPort}, filling::AbstractSystem, position::Position) =
  InnerBox{AbstractSystem,Position}(ports, filling, position)


"""
    InnerBox(ports::Dtry{InnerPort}, filling::AbstractSystem)

$(Doc_InnerBox)
$(Doc_InnerBox_Filling)
"""
InnerBox(ports::Dtry{InnerPort}, filling::AbstractSystem) =
  InnerBox{AbstractSystem,Nothing}(ports, filling, nothing)


"""
    InnerBox(ports::Dtry{InnerPort}, position::Position)

$(Doc_InnerBox)
"""
InnerBox(ports::Dtry{InnerPort}, position::Position) =
  InnerBox{Nothing,Position}(ports, nothing, position)


"""
    InnerBox(ports::Dtry{InnerPort})

$(Doc_InnerBox)
"""
InnerBox(ports::Dtry{InnerPort}) =
  InnerBox{Nothing,Nothing}(ports, nothing, nothing)


const Doc_Pattern = """
A (interconnection) `Pattern` is defined by
a directory of (possibly exposed) [`Junction`](@ref)s and
a directory of [`InnerBox`](@ref)es (subsystems),
whose ports are assigned to junctions, see [`InnerPort`](@ref).
The constructor checks that
* junctions and boxes have disjoint namespaces
* every port is connected/assigned to an existing junction
* every junction has at least one connected inner port
"""


"""
    Pattern{F,P}(junctions::Dtry{Junction{P}}, boxes::Dtry{InnerBox{F,P}}) where {F<:Union{Nothing,AbstractSystem},P<:Union{Nothing,Position}}

$(Doc_Pattern)

# Fields
- `junctions`: directory of junctions
- `boxes`: directory of inner boxes (subsystems)
"""
struct Pattern{F<:Union{Nothing,AbstractSystem},P<:Union{Nothing,Position}}
  junctions::Dtry{Junction{P}}
  boxes::Dtry{InnerBox{F,P}}

  function Pattern{F,P}(
    junctions::Dtry{Junction{P}},
    boxes::Dtry{InnerBox{F,P}};
    check::Bool=true
  ) where {F<:Union{Nothing,AbstractSystem},P<:Union{Nothing,Position}}
    if check
      junction_paths = Set{DtryPath}()
      foreachpath(junctions) do junction_path
        push!(junction_paths, junction_path)
        # TODO Why do we need disjoint namespaces?
        hasprefix(boxes, junction_path) &&
          error(
            "Namespaces of `junctions` and `boxes` are not distinct:" *
            " The junction path $(string(junction_path))" *
            " is a prefix found in `boxes`"
          )
      end
      foreach(boxes) do (box_path, box)
        foreach(box.ports) do (port_path, port)
          haspath(junctions, port.junction) ||
            error(
              "Port $(string(port_path)) of box $(string(box_path))" *
              " is connected to undefined junction $(string(port.junction))"
            )
          delete!(junction_paths, port.junction)
        end
        hasprefix(junctions, box_path) &&
          error(
            "Namespaces of `junctions` and `boxes` are not distinct:" *
            " The box path $(string(box_path))" *
            " is a prefix found in `junctions`"
          )
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


"""
    Pattern(junctions::Dtry{Junction{P}}, boxes::Dtry{InnerBox{F,P}}) where {F<:Union{Nothing,AbstractSystem},P<:Union{Nothing,Position}}

$(Doc_Pattern)
"""
Pattern(
  junctions::Dtry{Junction{P}},
  boxes::Dtry{InnerBox{F,P}};
  check::Bool=true
) where {F<:Union{Nothing,AbstractSystem},P<:Union{Nothing,Position}} =
  Pattern{F,P}(junctions, boxes; check)


"""
    Pattern{Nothing,Nothing}(pattern::Pattern{F,P})

Reduce a `Pattern{F,P}` to a `Pattern{Nothing,Nothing}` by forgetting
the filling of boxes as well as the positions of junctions and boxes.
"""
function Pattern{Nothing,Nothing}(pattern::Pattern)
  junctions = map(pattern.junctions, Junction{Nothing}) do junction
    Junction{Nothing}(junction.quantity, nothing, junction.exposed, junction.power)
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

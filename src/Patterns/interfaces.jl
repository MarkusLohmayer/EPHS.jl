
"""
    interface(pattern::Pattern) -> Interface

Returns the outer [`Interface`](@ref) of the given [`Pattern`](@ref).
"""
function AbstractSystems.interface(pattern::Pattern)
  filtermap(pattern.junctions, PortType) do junction
    (; exposed, quantity, power) = junction
    exposed ? Some(PortType(quantity, power)) : nothing
  end
end


"""
    interface(pattern::Pattern, box_path::DtryPath) -> Interface

Returns the [`Interface`](@ref) of the [`InnerBox`](@ref) with the given path.
"""
function AbstractSystems.interface(pattern::Pattern, box_path::DtryPath)
  box = pattern.boxes[box_path]
  map(box.ports, PortType) do port
    junction = pattern.junctions[port.junction]
    PortType(junction.quantity, port.power)
  end
end

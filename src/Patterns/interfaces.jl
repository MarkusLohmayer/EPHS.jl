
"Composite system interface"
function AbstractSystems.interface(pattern::Pattern)
  filtermap(pattern.junctions, PortType) do junction
    (; exposed, quantity, power) = junction
    exposed ? Some(PortType(quantity, power)) : nothing
  end
end


"Subsystem interface"
function AbstractSystems.interface(pattern::Pattern, subsystem::DtryPath)
  box = pattern.boxes[subsystem]
  map(box.ports, PortType) do (; junction, power)
    (; quantity) = pattern.junctions[junction]
    PortType(quantity, power)
  end
end

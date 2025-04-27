
"""
    assemble(sys::CompositeSystem) -> DAESystem

Assemble the system of differential(-algebraic) equations
corresponding to the given `CompositeSystem`.
"""
function assemble(sys::CompositeSystem)
  fsys = FlatSystem(sys)
  assemble(fsys)
end


function assemble(fsys::FlatSystem)
  storage = Vector{DAEStorage}()
  constraints = Vector{DAEConstraint}()
  foreach(fsys.pattern.boxes) do (box_path, box)
    if box.filling isa StorageComponent
      foreach(box.filling.ports) do (port_path, port)
        xvar = XVar(box_path, port_path)
        quantity = port.quantity
        flow = frompattern(fsys, FVar(xvar))
        effort = fromcomponent(fsys, EVar(xvar), box.filling)
        push!(storage, DAEStorage(xvar, quantity, flow, effort))
      end
    elseif box.filling isa ReversibleComponent
      foreach(box.filling.ports) do (port_path, port)
        if port.variant isa Constraint
          cvar = CVar(box_path, port_path)
          residual = replace(port.variant.residual, PortVar) do rhs_pvar
            frompattern(fsys, typeof(rhs_pvar)(box_path, rhs_pvar.port_path))
          end
          push!(constraints, DAEConstraint(cvar, residual))
        end
      end
    end
  end
  DAESystem(storage, constraints)
end

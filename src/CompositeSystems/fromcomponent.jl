
function fromcomponent(fsys::FlatSystem, pvar::PortVar)
  box = fsys.pattern.boxes[pvar.box_path]
  fromcomponent(fsys, pvar, box.filling)
end


fromcomponent(fsys::FlatSystem, pvar::PowerVar, c::Component) =
  replace(provide(c, pvar), Union{PortVar,CVar,Par}) do x
    if x isa PortVar
      frompattern(fsys, typeof(x)(pvar.box_path, x.port_path))
    elseif x isa CVar
      CVar(pvar.box_path, x.port_path)
    else # x isa Par
      if x.box_path == DtryPath(:ENV)
        x
      else
        Par(pvar.box_path, x.par_path, x.value)
      end
    end
  end


fromcomponent(::FlatSystem, xvar::XVar, sc::StorageComponent) =
  provide(sc, xvar)

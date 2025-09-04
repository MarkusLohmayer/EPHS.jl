
struct BoxPortPath
  box::DtryPath
  port::DtryPath
end


Base.print(io::IO, path::BoxPortPath) =
  print(io, path.box, '.', path.port)


struct JunctionInfo
  exposed::Bool
  power::Bool # external port is a power port (see Pattern)
  inner_connections::Vector{BoxPortPath}
  # 0 represents the outer port (implies `exposed==true`)
  # 1, 2, ... represent an index into `inner_connections`
  state_or_effort_provider::UInt8
  # More explicit alternative:
  # state_provider::Union{Nothing,UInt8}
  # effort_provider::Union{Nothing,UInt8}
  # Is there any connected inner port that consumes the shared state?
  state_consumer::Bool
end


function AbstractSystems.relation(sys::CompositeSystem)
  relations =
    map(box -> relation(box.filling), sys.pattern.boxes, Relation)
  junction_infos =
    mapwithpath(sys.pattern.junctions, JunctionInfo) do junction_path, junction
      inner_connections = Vector{BoxPortPath}()
      i::UInt8 = state_or_effort_provider::UInt8 = 0x0
      state_consumer = false
      foreach(sys.pattern.boxes) do (box_path, box)
        relation = relations[box_path]
        foreach(box.ports) do (port_path, inner_port)
          if inner_port.junction == junction_path
            path = BoxPortPath(box_path, port_path)
            port = relation.ports[port_path]
            i += 0x1
            if port.state_variant isa StateConsumer
              state_consumer = true
            end
            if port.state_variant isa StateProvider || port.power_variant isa EffortProvider
              state_or_effort_provider == 0x0 || error(
                "At junction $(print(junction_path)) both ports " *
                "$(print(inner_connections[state_or_effort_provider])) and " *
                "$(print(path)) want to set the state or effort variable."
              )
              state_or_effort_provider = i
            end
            push!(inner_connections, path)
          end
        end
      end
      !junction.exposed && state_or_effort_provider == 0x0 && error(
          "Junction $(print(junction_path)) is not exposed" *
          " and no connected port provides the state or effort variable."
        )
      JunctionInfo(
        junction.exposed,
        junction.power,
        inner_connections,
        state_or_effort_provider,
        state_consumer
      )
    end
  # The storage part of `relations` has three levels of nesting:
  # `outer_box_path * inner_box_path * port_path`
  # These correspond to the following three nested `map` operations.
  # Finally, `flatten` combines the `outer_box_path` and the `inner_box_path`.
  storage =
    mapwithpath(relations, Dtry{Dtry{SymExpr}}) do box_path, relation
      map(relation.storage, Dtry{SymExpr}) do dtry
        map(dtry, SymExpr) do flow
          prefix_box_path_and_resolve(
            sys.pattern, relations, junction_infos, box_path, flow
          )
        end
      end
    end |> flatten
  constraints =
    mapwithpath(relations, Dtry{Dtry{SymExpr}}) do box_path, relation
      map(relation.constraints, Dtry{SymExpr}) do dtry
        map(dtry, SymExpr) do residual
          prefix_box_path_and_resolve(
            sys.pattern, relations, junction_infos, box_path, residual
          )
        end
      end
    end |> flatten
  ports =
    filtermap(junction_infos, Port) do junction_info
      junction_info.exposed || return nothing
      i = junction_info.state_or_effort_provider
      if i != 0x00 # an inner port provides the state and/or effort
        path = junction_info.inner_connections[i]
        relation = relations[path.box]
        port = relation.ports[path.port]
        if port.state_variant isa StateProvider
          xvar = port.state_variant.xvar
          xvar = XVar(path.box * xvar.box_path, xvar.port_path)
          state_variant = StateProvider(xvar)
        else
          # Combination StateConsumer,EffortProvider not meaningful
          @assert isnothing(port.state_variant)
          state_variant = nothing
        end
        if junction_info.power
          @assert port.power_variant isa EffortProvider
          effort = prefix_box_path_and_resolve(
            sys.pattern, relations, junction_infos, path.box, port.power_variant.effort
          )
          power_variant = EffortProvider(effort)
        else
          power_variant = nothing
        end
      else # the state and/or effort is determined by the outer port
        if junction_info.state_consumer
          state_variant = StateConsumer() # looking from outside
        else
          state_variant = nothing
        end
        if junction_info.power
          flow = Const(0.0)
          for path in junction_info.inner_connections
            relation = relations[path.box]
            port = relation.ports[path.port]
            isnothing(port.power_variant) && continue
            @assert port.power_variant isa FlowProvider
            flow += prefix_box_path_and_resolve(
              sys.pattern, relations, junction_infos, path.box, port.power_variant.flow
            )
          end
          power_variant = FlowProvider(flow)
        else
          power_variant = nothing
        end
      end
      return Some(Port(state_variant, power_variant))
    end
  Relation(storage, constraints, ports)
end


function resolve(
  pattern::Pattern,
  relations::Dtry{Relation},
  junction_infos::Dtry{JunctionInfo},
  fvar::FVar
)
  (; box_path, port_path) = fvar
  @assert box_path !== DtryPath() # not called to resolve flow variables of outer ports
  box = pattern.boxes[box_path]
  inner_port = box.ports[port_path]
  junction_path = inner_port.junction
  junction_info = junction_infos[junction_path]
  (; exposed, power, inner_connections, state_or_effort_provider) = junction_info
  flow = Const(0.0)
  # outer
  if exposed && power && state_or_effort_provider != 0
    # if !(box_path == DtryPath() && port_path == junction_path)
      flow += FVar(DtryPath(), junction_path)
    # end
  end
  # inner
  for path in inner_connections
    path.box == box_path && path.port == port_path && continue
    relation = relations[path.box]
    port = relation.ports[path.port]
    isnothing(port.power_variant) && continue
    @assert port.power_variant isa FlowProvider
    flow -= prefix_box_path_and_resolve(
      pattern, relations, junction_infos, path.box, port.power_variant.flow
    )
  end
  flow
end


function resolve(
  pattern::Pattern,
  relations::Dtry{Relation},
  junction_infos::Dtry{JunctionInfo},
  evar::EVar
)
  (; box_path, port_path) = evar
  box = pattern.boxes[box_path]
  inner_port = box.ports[port_path]
  junction_path = inner_port.junction
  junction_info = junction_infos[junction_path]
  i = junction_info.state_or_effort_provider
  if i == 0
    @assert junction_info.exposed && junction_info.power
    return EVar(DtryPath(), junction_path)
  else
    path = junction_info.inner_connections[i]
    relation = relations[path.box]
    port = relation.ports[path.port]
    @assert port.power_variant isa EffortProvider
    effort = port.power_variant.effort
    return prefix_box_path_and_resolve(
      pattern, relations, junction_infos, path.box, effort
    )
  end
end


# Defined analogously to resolve for EVar
function resolve(
  pattern::Pattern,
  relations::Dtry{Relation},
  junction_infos::Dtry{JunctionInfo},
  xvar::XVar
)
  (; box_path, port_path) = xvar
  box = pattern.boxes[box_path]
  inner_port = box.ports[port_path]
  junction_path = inner_port.junction
  junction_info = junction_infos[junction_path]
  i = junction_info.state_or_effort_provider
  if i == 0
    @assert junction_info.exposed
    return XVar(DtryPath(), junction_path)
  else
    path = junction_info.inner_connections[i]
    relation = relations[path.box]
    port = relation.ports[path.port]
    @assert port.state_variant isa StateProvider
    xvar = port.state_variant.xvar
    return prefix_box_path_and_resolve(
      pattern, relations, junction_infos, path.box, xvar
    )
  end
end


prefix_box_path_and_resolve(
  pattern::Pattern,
  relations::Dtry{Relation},
  junction_infos::Dtry{JunctionInfo},
  box_path::DtryPath,
  expr::SymExpr
) = begin
  replace(expr, Union{PortVar,CVar,Par}) do x
    if x isa XVar
      xvar = XVar(box_path * x.box_path, x.port_path)
      if x.box_path == DtryPath() # external state variable of subsystem
        ports = relations[box_path].ports
        port = ports[x.port_path] # respective port of the subsystem
        if port.state_variant isa StateConsumer
          xvar = resolve(pattern, relations, junction_infos, xvar)
        end
      end
      xvar
    elseif x isa PowerVar
      pvar = typeof(x)(box_path * x.box_path, x.port_path)
      resolve(pattern, relations, junction_infos, pvar)
    elseif x isa CVar
      CVar(box_path, x.port_path)
    else # x isa Par
      if x.box_path == DtryPath(:ENV)
        x
      else
        Par(box_path * x.box_path, x.par_path, x.value)
      end
    end
  end
end

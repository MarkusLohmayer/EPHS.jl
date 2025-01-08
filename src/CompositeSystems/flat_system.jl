
"Connection of an `InnerPort` to a `Junction`"
struct Connection
  box_path::DtryPath      # box to which the port belongs
  port_path::DtryPath     # name of the port
  power::Bool             # true means port is a power port
  storage::Bool           # true means port belongs to a StorageComponent
  effort_provider::Bool   # true means port provides effort variable
  state_provider::Bool    # true means port provides state variable
end


struct FlatSystem
  pattern::Pattern{AbstractSystem,P} where {P}
  connections::Dtry{Vector{Connection}}

  """
  Prepare `CompositeSystem` for assembly of equations
  """
  function FlatSystem(
    sys::CompositeSystem{P}
  ) where {P<:Union{Nothing,Position}}
    # Flatten system
    sys_flat = flatten(sys)
    # Identify `Connection`s at each junction
    connections = map(_ -> Vector{Connection}(), sys_flat.pattern.junctions)
    foreach(sys_flat.pattern.boxes) do (box_path, box)
      storage = box.filling isa StorageComponent
      foreach(box.ports) do (port_path, (; junction, power))
        effort_provider = storage || provides(box.filling, EVar(DtryPath(), port_path))
        state_provider = storage || provides(box.filling, XVar(DtryPath(), port_path))
        c = Connection(box_path, port_path, power, storage, effort_provider, state_provider)
        push!(connections[junction], c)
      end
    end
    # Check that there is at most one effort and state provider per junction
    foreach(connections) do (junction_path, cs)
      effort_providers::Int = mapreduce(c -> c.effort_provider, +, cs)
      effort_providers ≤ 1 || error(
        "At junction $(string(junction_path)) there are" *
        " $(effort_providers) connections that provide an effort variable"
      )
      state_providers::Int = mapreduce(c -> c.state_provider, +, cs)
      state_providers ≤ 1 || error(
        "At junction $(string(junction_path)) there are" *
        " $(state_providers) connections that provide a state variable"
      )
    end
    new(sys_flat.pattern, connections)
  end
end


Base.show(io::IO, ::MIME"text/plain", fsys::FlatSystem) =
  print(io, fsys.pattern)


Base.print(io::IO, fsys::FlatSystem) =
  print(io, fsys.pattern)

# State            Power,
# ---------------------------------
# Nothing          Nothing          (obviously not meaningful)
# StateProvider    Nothing          (port bₛ of stator)
# StateConsumer    Nothing          (port bₛ of mkc and rotor)
# Nothing          FlowProvider     (generalized gyrators, irreversible components)
# StateProvider    FlowProvider     (seemingly not meaningful)
# StateConsumer    FlowProvider     (mass/entropy port of advection)
# Nothing          EffortProvider   (transformer)
# StateProvider    EffortProvider   (port of a storage component)
# StateConsumer    EffortProvider   (seemingly not meaningful)


abstract type StateVariant end


struct StateProvider <: StateVariant
  xvar::XVar
end


struct StateConsumer <: StateVariant
end


abstract type PowerVariant end


struct FlowProvider <: PowerVariant
  flow::SymExpr
end


struct EffortProvider <: PowerVariant
  effort::SymExpr
end


struct Port
  state_variant::Union{StateProvider,StateConsumer,Nothing}
  power_variant::Union{FlowProvider,EffortProvider,Nothing}

  Port(state_variant::StateVariant) =
    new(state_variant, nothing)
  Port(power_variant::PowerVariant) =
    new(nothing, power_variant)
  # Port(state_variant::StateVariant, power_variant::PowerVariant) =
  #   new(state_variant, power_variant)
  function Port(state_variant, power_variant)
    isnothing(state_variant) && isnothing(power_variant) && error(
      "Port(nothing, nothing) is not possible"
    )
    new(state_variant, power_variant)
  end
end


"""
    Relation(storage::Dtry{SymExpr}, external::Dtry{Provider})

A relation that defines the semantics of a system.
"""
@kwdef struct Relation
  storage::Dtry{Dtry{SymExpr}} = Dtry{Dtry{SymExpr}}()
  constraints::Dtry{Dtry{SymExpr}} = Dtry{Dtry{SymExpr}}()
  ports::Dtry{Port} = Dtry{Port}()
end


Base.show(io::IO, ::MIME"text/plain", relation::Relation) =
  print(io, relation)


function Base.print(io::IO, relation::Relation)
  flag = false # for line breaks between sections
  if !isempty(relation.storage)
    flag = true
    println(io, "Storage:")
    print_dtry(io, relation.storage; print_value=print_storage)
  end
  if !isempty(relation.constraints)
    flag && println(io)
    flag = true
    println(io, "Constraints:")
    print_dtry(io, relation.constraints; print_value=print_constraints)
  end
  if !isempty(relation.ports)
    flag && println(io)
    println(io, "Ports:")
    print_dtry(io, relation.ports; print_value=print_port)
  end
end


print_storage(io::IO, storage::Dtry{SymExpr}, prefix::String) =
  print_dtry(io, storage; print_value=print_storage_flow, prefix)


print_storage_flow(io::IO, flow::SymExpr, _::String) =
  print(io, "f = ", flow)


print_constraints(io::IO, constraints::Dtry{SymExpr}, prefix::String) =
  print_dtry(io, constraints; print_value=print_constraint_residual, prefix)


print_constraint_residual(io::IO, residual::SymExpr, _::String) =
  print(io, "0 = ", residual)


function print_port(io::IO, port::Port, prefix::String)
  flag = false # for line breaks between sections
  if !isnothing(port.state_variant)
    flag = true
    print_port(io, port.state_variant)
  end
  if !isnothing(port.power_variant)
    flag && print(io, '\n', prefix)
    print_port(io, port.power_variant)
  end
end


print_port(io::IO, provider::StateProvider) =
  print(io, "x = ", provider.xvar)


print_port(io::IO, _::StateConsumer) =
  print(io, "state consumer")


print_port(io::IO, provider::FlowProvider) =
  print(io, "f = ", provider.flow)


print_port(io::IO, provider::EffortProvider) =
  print(io, "e = ", provider.effort)

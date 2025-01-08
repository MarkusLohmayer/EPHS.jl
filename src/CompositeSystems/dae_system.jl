
struct DAEStorage
  xvar::XVar
  quantity::Quantity
  flow::SymExpr
  effort::SymExpr
end


struct DAEConstraint
  cvar::CVar
  residual::SymExpr
end


struct DAESystem
  storages::Vector{DAEStorage}
  constraints::Vector{DAEConstraint}
end


Base.show(io::IO, ::MIME"text/plain", dae::DAESystem) =
  print(io, dae)


function Base.print(io::IO, dae::DAESystem)
  if !isempty(dae.storages)
    println(io, "Flows:")
    foreach(dae.storages) do (; xvar, flow)
      println(io, string(FVar(xvar)), " = ", string(flow))
    end
    println(io, "Efforts:")
    foreach(dae.storages) do (; xvar, effort)
      println(io, string(EVar(xvar)), " = ", string(effort))
    end
  end
  if !isempty(dae.constraints)
    println(io, "Constraints:")
    foreach(dae.constraints) do (; cvar, residual)
      println(io, "0 = ", string(residual), "  enforced by ", string(cvar))
    end
  end
end


# Used for testing:

function equations(dae::DAESystem)
  eqs = Vector{Eq}()
  foreach(dae.storages) do (; xvar, flow, effort)
    lhs = FVar(xvar)
    rhs = map(flow, EVar) do evar
      index = findfirst(dae.storages) do (; xvar)
        xvar == XVar(evar)
      end
      isnothing(index) ? evar : dae.storages[index].effort
    end
    push!(eqs, Eq(lhs, rhs))
  end
  foreach(dae.constraints) do (; residual)
    lhs = Const(0.)
    rhs = map(residual, EVar) do evar
      index = findfirst(dae.storages) do (; xvar)
        xvar == XVar(evar)
      end
      isnothing(index) ? evar : dae.storages[index].effort
    end
    push!(eqs, Eq(lhs, rhs))
  end
  eqs
end


Base.:(==)(lhs::DAESystem, rhs::DAESystem) =
  lhs.storages == rhs.storages && lhs.constraints == rhs.constraints

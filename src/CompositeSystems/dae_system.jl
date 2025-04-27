
"""
    DAEStorage(xvar::XVar, quantity::Quantity, flow::SymExpr, effort::SymExpr)

# Fields
- `xvar`: state variable
- `quantity`: associated [`EPHS.AbstractSystems.Quantity`]
- `flow`: the time-derivative of the state variable
- `effort`: the differential of the exergy function w.r.t. the state variable
"""
struct DAEStorage
  xvar::XVar
  quantity::Quantity
  flow::SymExpr
  effort::SymExpr
end


"""
    DAEConstraint(cvar::CVar, residual::SymExpr)

The `residual` is forced to be zero by
the corresponding constraint variable `cvar`.
"""
struct DAEConstraint
  cvar::CVar
  residual::SymExpr
end


"""
    DAESystem(storage::Vector{DAEStorage}, constraints::Vector{DAEConstraint})

A `DAESystem` defines a system of differential(-algebraic) equations.

# Fields
- `storage`: differential part (evolution of state variables)
- `constraints`: algebraic part (residuals forced to be zero by constraint variables)

See [`DAEStorage`](@ref) and [`DAEConstraint`](@ref).
"""
struct DAESystem
  storage::Vector{DAEStorage}
  constraints::Vector{DAEConstraint}
end


Base.show(io::IO, ::MIME"text/plain", dae::DAESystem) =
  print(io, dae)


function Base.print(io::IO, dae::DAESystem)
  if !isempty(dae.storage)
    println(io, "Flows:")
    foreach(dae.storage) do (; xvar, flow)
      println(io, string(FVar(xvar)), " = ", string(flow))
    end
    println(io, "Efforts:")
    foreach(dae.storage) do (; xvar, effort)
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


"""
    update_parameters(dae::DAESystem, ps::Dtry{Float64}) -> DAESystem

Update the parameters of the given `DAESystem`
according to the directory of parameters `ps`.
Parameters that are not contained in `ps` remain unchanged.
Parameters in `ps` that are not present in the system are ignored.
"""
function update_parameters(dae::DAESystem, ps::AbstractDtry{Float64})
  isempty(ps) && return dae
  storage = map(dae.storage) do storage
    flow = replace(storage.flow, Par) do par
      value = get(ps, par.box_path * par.par_path, par.value)
      Par(par.box_path, par.par_path, value)
    end
    effort = replace(storage.effort, Par) do par
      value = get(ps, par.box_path * par.par_path, par.value)
      Par(par.box_path, par.par_path, value)
    end
    DAEStorage(storage.xvar, storage.quantity, flow, effort)
  end
  constraints = map(dae.constraints) do constraint
    residual = replace(constraint.residual, Par) do par
      value = get(ps, par.box_path * par.par_path, par.value)
      Par(par.box_path, par.par_path, value)
    end
    DAEConstraint(constraint.cvar, residual)
  end
  DAESystem(storage, constraints)
end


# Used for testing:

function equations(dae::DAESystem)
  eqs = Vector{Eq}()
  foreach(dae.storage) do (; xvar, flow)
    lhs = FVar(xvar)
    rhs = replace(flow, EVar) do evar
      index = findfirst(dae.storage) do (; xvar)
        xvar == XVar(evar)
      end
      isnothing(index) ? evar : dae.storage[index].effort
    end
    push!(eqs, Eq(lhs, rhs))
  end
  foreach(dae.constraints) do (; residual)
    lhs = Const(0.)
    rhs = replace(residual, EVar) do evar
      index = findfirst(dae.storage) do (; xvar)
        xvar == XVar(evar)
      end
      isnothing(index) ? evar : dae.storage[index].effort
    end
    push!(eqs, Eq(lhs, rhs))
  end
  eqs
end


Base.:(==)(lhs::DAESystem, rhs::DAESystem) =
  lhs.storage == rhs.storage && lhs.constraints == rhs.constraints

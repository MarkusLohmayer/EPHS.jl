
"""
    evolution(sim::SimulationResult, xvar::Xvar)

Returns a `Vector{Float64}` containing
the values of the given state variable at each time instant.
"""
function evolution(sim::SimulationResult, xvar::XVar)
  i = findfirst(s -> (s.xvar == xvar), sim.dae.storage)
  isnothing(i) && error("$(string(xvar)) not found")
  [x[i] for x in sim.xs]
end


function evolution(dae::DAESystem, xs::Vector, expr::SymExpr)
  foreach(expr, Union{PortVar,CVar}) do var
    var isa XVar ||
      error("$(string(var)) is not a `XVar`")
    isnothing(findfirst(s -> (s.xvar == var), dae.storage)) &&
      error("$(string(var)) not found")
  end

  expr_unpack = Expr(
    :(=),
    Expr(
      :tuple,
      (ast(xvar) for (; xvar) in dae.storage)...
    ),
    :(x)
  )

  expr_f = Expr(
    :function,
    :(f(x)),
    Expr(
      :block,
      expr_unpack,
      ast(expr)
    ),
  )

  f = @RuntimeGeneratedFunction(expr_f)

  map(f, xs)
end



"""
    evolution(sim::SimulationResult, expr::SymExpr)

Evaluates the given [`SymExpr`](@ref) at each time step,
given that the expression depends only on the state variables.
"""
evolution(sim::SimulationResult, expr::SymExpr) =
  evolution(sim.dae, sim.xs, expr)

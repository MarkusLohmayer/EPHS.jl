
# Simple hack to make simulation work for systems with external ports
_isolate(flow::SymExpr) =
  map(flow, FVar) do fvar
    fvar.box_path == ■ ? Const(0.0) : fvar
  end


"""
    midpoint_rule(dae::DAESystem)

Generate a Julia function that performs a state update `x₀ ↦ x₁`
based on the implicit midpoint discretization.
This is a symplectic, second-order Gauss method.
For constrained systems, the state is augmented with
the constraint variables.
"""
function midpoint_rule(dae::DAESystem)

  expr_unpack_x₀ = Expr(
    :(=),
    Expr(
      :tuple,
      (ast(xvar, "₀") for (; xvar) in dae.storage)...,
      (ast(cvar) for (; cvar) in dae.constraints)... # not needed
    ),
    :x₀
  )

  expr_unpack_x₁ = Expr(
    :(=),
    Expr(
      :tuple,
      (ast(xvar, "₁") for (; xvar) in dae.storage)...,
      (ast(cvar) for (; cvar) in dae.constraints)...
    ),
    :x₁
  )

  expr_midpoint = Expr[
    Expr(
      :(=),
      ast(xvar),
      :(($(ast(xvar, "₀")) + $(ast(xvar, "₁"))) / 2)
    )
    for (; xvar) in dae.storage
  ]

  expr_efforts = Expr[
    Expr(
      :(=),
      ast(EVar(xvar)),
      ast(effort)
    )
    for (; xvar, effort) in dae.storage
  ]

  expr_residual_vect = Expr(
    :ref,
    :SA,
    (:($(ast(xvar, "₁")) - $(ast(xvar, "₀")) - h * ($(ast(_isolate(flow))))) for (; xvar, flow) in dae.storage)...,
    (ast(residual) for (; residual) in dae.constraints)...
  )

  expr_solve_x₁ = :(x₁ = nlsolve(residual, x₀))

  expr_update = Expr(
    :function,
    :(update(x₀, h)),
    Expr(
      :block,
      expr_unpack_x₀,
      Expr(
        :function,
        :(residual(x₁)),
        Expr(
          :block,
          expr_unpack_x₁,
          expr_midpoint...,
          expr_efforts...,
          expr_residual_vect
        )
      ),
      expr_solve_x₁
    )
  )

  @RuntimeGeneratedFunction(expr_update)
end

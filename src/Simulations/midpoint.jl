
function midpoint_rule(sys::CompositeSystem)
  dae = assemble(sys)

  isempty(dae.constraints) ||
    error("`midpoint_rule` does not work with constrained systems")

  expr_unpack_x₀ = Expr(
    :(=),
    Expr(
      :tuple,
      (ast0(xvar) for (; xvar) in dae.storages)...
    ),
    :x₀
  )

  expr_unpack_x₁ = Expr(
    :(=),
    Expr(
      :tuple,
      (ast1(xvar) for (; xvar) in dae.storages)...
    ),
    :x₁
  )

  expr_midpoint = Expr[
    Expr(
      :(=),
      ast(xvar),
      :( ($(ast0(xvar)) + $(ast1(xvar))) / 2 )
    )
    for (; xvar) in dae.storages
  ]

  expr_efforts = Expr[
    Expr(
      :(=),
      ast(EVar(xvar)),
      ast(effort)
    )
    for (; xvar, effort) in dae.storages
  ]

  expr_residual = Expr[
    :(($(ast1(xvar)) - $(ast0(xvar))) - h * ($(ast(flow))))
    for (; xvar, flow) in dae.storages
  ]

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
          Expr(
            :ref,
            :SA,
            expr_residual...
          )
        )
      ),
      expr_solve_x₁
    )
  )

  @RuntimeGeneratedFunction(expr_update)
end

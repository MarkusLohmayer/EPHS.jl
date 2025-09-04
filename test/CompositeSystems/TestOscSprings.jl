"""
mechanical oscillator with constraint (two springs in series)
"""
module TestOscConstraintSprings

using Test, EPHS

osc_constraint = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(displacement, Position(1, 2))),
    :p => Dtry(Junction(momentum, Position(1, 4))),
    :q₂ => Dtry(Junction(displacement, Position(3, 2))),
  ),
  Dtry(
    :pe => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
        ),
        hookean_spring(k=1.5),
        Position(1, 1)
      ),
    ),
    :ke => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        point_mass(m=1.0),
        Position(1, 5)
      ),
    ),
    :pkc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
          :p => Dtry(InnerPort(■.p))
        ),
        pkc,
        Position(1, 3)
      ),
    ),
    :sc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
          :q₂ => Dtry(InnerPort(■.q₂)),
        ),
        two_springs_series_connection,
        Position(2, 2)
      ),
    ),
    :pe₂ => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q₂)),
        ),
        hookean_spring(k=1.5),
        Position(3, 1)
      ),
    ),
  )
)

@test assemble(osc_constraint) |> equations == Eq[
  Eq(FVar(■.ke, ■.p), Mul((Const(-1.0), Par(■.pe, ■.k, 1.5), XVar(■.pe, ■.q)))),
  Eq(FVar(■.pe, ■.q), Add((Mul((XVar(■.ke, ■.p), Pow(Par(■.ke, ■.m, 1.0), Const(-1.0)))), Mul((Const(-1.0), CVar(■.sc, ■.λ)))))),
  Eq(FVar(■.pe₂, ■.q), CVar(■.sc, ■.λ)),
  Eq(Const(0.0), Add((Mul((Const(-1.0), Par(■.pe, ■.k, 1.5), XVar(■.pe, ■.q))), Mul((Par(■.pe₂, ■.k, 1.5), XVar(■.pe₂, ■.q))))))
]

@test relation(osc_constraint) == Relation(;
  storage=Dtry(
    :ke => Dtry(
      Dtry(
        :p => Dtry{SymExpr}(Mul((Const(-1.0), Par(■.pe, ■.k, 1.5), XVar(■.pe, ■.q))))
      )
    ),
    :pe => Dtry(
      Dtry(
        :q => Dtry{SymExpr}(Add((Mul((XVar(■.ke, ■.p), Pow(Par(■.ke, ■.m, 1.0), Const(-1.0)))), Mul((Const(-1.0), CVar(■.sc, ■.λ))))))
      )
    ),
    :pe₂ => Dtry(
      Dtry(
        :q => Dtry{SymExpr}(CVar(■.sc, ■.λ))
      )
    )
  ),
  constraints=Dtry(
    :sc => Dtry(
      Dtry(
        :λ => Dtry{SymExpr}(Add((Mul((Const(-1.0), Par(■.pe, ■.k, 1.5), XVar(■.pe, ■.q))), Mul((Par(■.pe₂, ■.k, 1.5), XVar(■.pe₂, ■.q))))))
      )
    )
  )
)

# 16.708 μs (324 allocations: 11.83 KiB) DAESystem
# 48.625 μs (868 allocations: 31.19 KiB) Symbolic differentiation (with simplification/normalization)
# @btime assemble($osc_constraint);

end

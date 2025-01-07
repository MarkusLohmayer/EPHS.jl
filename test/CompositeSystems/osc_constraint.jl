# mechanical oscillator with constraint (two springs in series)

hc = ReversibleComponent(
  Dtry(
    :q => Dtry(ReversiblePort(FlowPort(displacement, CVar(:λ)))),
    :q₂ => Dtry(ReversiblePort(FlowPort(displacement, -CVar(:λ)))),
    :λ => Dtry(ReversiblePort(Constraint(-EVar(:q) + EVar(:q₂))))
  )
)

osc_constraint = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(false, displacement, true, Position(1, 2))),
    :p => Dtry(Junction(false, momentum, true, Position(1, 4))),
    :q₂ => Dtry(Junction(false, displacement, true, Position(3, 2))),
  ),
  Dtry(
    :pe => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q, true)),
        ),
        pe,
        Position(1, 1)
      ),
    ),
    :ke => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p, true)),
        ),
        ke,
        Position(1, 5)
      ),
    ),
    :pkc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q, true)),
          :p => Dtry(InnerPort(■.p, true))
        ),
        pkc,
        Position(1, 3)
      ),
    ),
    :hc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q, true)),
          :q₂ => Dtry(InnerPort(■.q₂, true)),
        ),
        hc,
        Position(2, 2)
      ),
    ),
    :pe₂ => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q₂, true)),
        ),
        pe,
        Position(3, 1)
      ),
    ),
  )
);

@test assemble(osc_constraint) == Eq[
  Eq(FVar(■.pe, ■.q), Neg(Add((Neg(Div(XVar(■.ke, ■.p), Const(1.0))), CVar(■.hc, ■.λ)))))
  Eq(FVar(■.ke, ■.p), Neg(Mul((Const(1.5), XVar(■.pe, ■.q)))))
  Eq(Const(0.0), Add((Neg(Mul((Const(1.5), XVar(■.pe, ■.q)))), Mul((Const(1.5), XVar(■.pe₂, ■.q))))))
  Eq(FVar(■.pe₂, ■.q), CVar(■.hc, ■.λ))
]

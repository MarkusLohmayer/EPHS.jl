
lever = ReversibleComponent(
  Dtry(
    :q₁ => Dtry(ReversiblePort(FlowPort(displacement, -(Const(2.) * FVar(:q₂))))),
    :q₂ => Dtry(ReversiblePort(EffortPort(displacement, Const(2.) * EVar(:q₁))))
  )
)

osc_damped_lever = CompositeSystem(
  Dtry(
    :q₁ => Dtry(Junction(false, displacement, true, Position(1,2))),
    :q₂ => Dtry(Junction(false, displacement, true, Position(1,4))),
    :p => Dtry(Junction(false, momentum, true, Position(1,6))),
    :s => Dtry(Junction(false, entropy, true, Position(2,7))),
  ),
  Dtry(
    :pe => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q₁, true)),
        ),
        pe,
        Position(1,1)
      ),
    ),
    :lever => Dtry(
      InnerBox(
        Dtry(
          :q₁ => Dtry(InnerPort(■.q₁, true)),
          :q₂ => Dtry(InnerPort(■.q₂, true))
        ),
        lever,
        Position(1,3)
      ),
    ),
    :pkc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q₂, true)),
          :p => Dtry(InnerPort(■.p, true))
        ),
        pkc,
        Position(1,5)
      ),
    ),
    :ke => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p, true)),
        ),
        ke,
        Position(1,7)
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p, true)),
          :s => Dtry(InnerPort(■.s, true)),
        ),
        mf,
        Position(2,6)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s, true)),
        ),
        tc,
        Position(2,8)
      ),
    ),
  )
);

@test assemble(osc_damped_lever) == Eq[
  Eq(FVar(■.pe, ■.q), Mul((Const(2.0), Div(XVar(■.ke, ■.p), Const(1.0))))),
  Eq(FVar(■.ke, ■.p), Neg(Add((Mul((Const(2.0), Mul((Const(1.5), XVar(■.pe, ■.q))))), Mul((Const(0.02), Div(XVar(■.ke, ■.p), Const(1.0)))))))),
  Eq(FVar(■.tc, ■.s), Div(Mul((Const(0.02), Div(XVar(■.ke, ■.p), Const(1.0)), Div(XVar(■.ke, ■.p), Const(1.0)))), Mul((Div(Const(1.0), Const(2.5)), Exp(Div(XVar(■.tc, ■.s), Const(2.5)))))))
]

# 32.083 μs (732 allocations: 22.30 KiB) top-down approach
# 18.833 μs (504 allocations: 15.91 KiB) hybrid approach, 41% less runtime
# 11.500 μs (345 allocations: 11.69 KiB) recursive approach, 64% less runtime than top-down approach
# 36.125 μs (672 allocations: 26.00 KiB) two levels of nesting, state ports
# 42.666 μs (781 allocations: 30.59 KiB) arbitrary nesting of patterns
# 13.208 μs (332 allocations: 11.56 KiB) refactor Position, convenience constructors
# 22.958 μs (506 allocations: 16.66 KiB) components as values, dtry
# @btime assemble($osc_damped_lever);


lever = let
  r = Par(:r, 2.)
  q₁₊e = EVar(:q₁)
  q₂₊f = FVar(:q₂)
  q₁₊f = -(r * q₂₊f)
  q₂₊e = r * q₁₊e
  ReversibleComponent(
    Dtry(
      :q₁ => Dtry(ReversiblePort(FlowPort(displacement, q₁₊f))),
      :q₂ => Dtry(ReversiblePort(EffortPort(displacement, q₂₊e)))
    )
  )
end

osc_damped_lever = CompositeSystem(
  Dtry(
    :q₁ => Dtry(Junction(displacement, Position(1,2))),
    :q₂ => Dtry(Junction(displacement, Position(1,4))),
    :p => Dtry(Junction(momentum, Position(1,6))),
    :s => Dtry(Junction(entropy, Position(2,7))),
  ),
  Dtry(
    :pe => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q₁)),
        ),
        pe,
        Position(1,1)
      ),
    ),
    :lever => Dtry(
      InnerBox(
        Dtry(
          :q₁ => Dtry(InnerPort(■.q₁)),
          :q₂ => Dtry(InnerPort(■.q₂))
        ),
        lever,
        Position(1,3)
      ),
    ),
    :pkc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q₂)),
          :p => Dtry(InnerPort(■.p))
        ),
        pkc,
        Position(1,5)
      ),
    ),
    :ke => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        ke,
        Position(1,7)
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :s => Dtry(InnerPort(■.s)),
        ),
        mf,
        Position(2,6)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        tc,
        Position(2,8)
      ),
    ),
  )
);

@test assemble(osc_damped_lever) |> equations == Eq[
  Eq(FVar(■.ke, ■.p), Add((Mul((Const(-1.0), Par(■.mf, ■.d, 0.02), XVar(■.ke, ■.p), Pow(Par(■.ke, ■.m, 1.0), Const(-1.0)))), Mul((Const(-1.0), Par(■.lever, ■.r, 2.0), Par(■.pe, ■.k, 1.5), XVar(■.pe, ■.q)))))),
  Eq(FVar(■.pe, ■.q), Mul((Par(■.lever, ■.r, 2.0), XVar(■.ke, ■.p), Pow(Par(■.ke, ■.m, 1.0), Const(-1.0))))),
  Eq(FVar(■.tc, ■.s), Mul((Par(■.mf, ■.d, 0.02), Pow(XVar(■.ke, ■.p), Const(2.0)), Pow(Par(■.ke, ■.m, 1.0), Const(-2.0)), Pow(Par(■.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.tc, ■.s), Pow(Par(■.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.tc, ■.c₂, 2.0))))
]

# 32.083 μs (732 allocations: 22.30 KiB) top-down approach
# 18.833 μs (504 allocations: 15.91 KiB) hybrid approach, 41% less runtime
# 11.500 μs (345 allocations: 11.69 KiB) recursive approach, 64% less runtime than top-down approach
# 36.125 μs (672 allocations: 26.00 KiB) two levels of nesting, state ports
# 42.666 μs (781 allocations: 30.59 KiB) arbitrary nesting of patterns
# 13.208 μs (332 allocations: 11.56 KiB) refactor Position, convenience constructors
# 22.958 μs (506 allocations: 16.66 KiB) components as values, dtry
# 24.708 μs (486 allocations: 16.91 KiB) DAESystem
# 91.875 μs (1545 allocations: 55.12 KiB) Symbolic differentiation (with simplification/normalization)
# @btime assemble($osc_damped_lever);

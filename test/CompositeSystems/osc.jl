# mechanical oscillator

pe = HookeanSpring(Const(1.5));
ke = PointMass(Const(1.));
pkc = PKC();

osc = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(false, displacement, true, Position(1,2))),
    :p => Dtry(Junction(true, momentum, true, Position(1,4))),
  ),
  Dtry(
    :pe => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q, true)),
        ),
        pe,
        Position(1,1)
      ),
    ),
    :ke => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p, true)),
        ),
        ke,
        Position(1,5)
      ),
    ),
    :pkc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q, true)),
          :p => Dtry(InnerPort(■.p, true))
        ),
        pkc,
        Position(1,3)
      ),
    ),
  )
);

@test assemble(osc) == Eq[
  Eq(FVar(■.pe, ■.q), Div(XVar(■.ke, ■.p), Const(1.0))),
  Eq(FVar(■.ke, ■.p), Add((Neg(Mul((Const(1.5), XVar(■.pe, ■.q)))), FVar(■, ■.p))))
]

# Human-readable display of equations
# assemble(osc) |> print

# 7.812 μs (205 allocations: 6.52 KiB) top-down approach
# 6.400 μs (167 allocations: 5.53 KiB hybrid approach
# 6.008 μs (156 allocations: 5.25 KiB) recursive approach
# 25.166 μs (377 allocations: 13.55 KiB) two levels of nesting, state ports
# 28.750 μs (448 allocations: 16.25 KiB) arbitrary nesting of patterns
# 28.334 μs (431 allocations: 15.89 KiB)
# 7.021 μs (173 allocations: 5.95 KiB) isflat
# 7.052 μs (167 allocations: 5.78 KiB) refactor Position, convenience constructors
# @btime assemble($osc)

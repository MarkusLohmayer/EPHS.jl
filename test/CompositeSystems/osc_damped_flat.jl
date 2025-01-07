
tc = let
  c₁ = Par(:c₁, 1.0)
  c₂ = Par(:c₂, 2.0)
  s = XVar(:s)
  E = c₁ * exp(s / c₂)
  StorageComponent(
    Dtry(
      :s => Dtry(entropy)
    ),
    E
  )
end

mf = let
  d = Par(:d, 0.02)
  p₊e = EVar(:p)
  s₊e = EVar(:s)
  p₊f = d * p₊e
  s₊f = -((d * p₊e * p₊e) / (θ₀ + s₊e))
  IrreversibleComponent(
    Dtry(
      :p => Dtry(IrreversiblePort(momentum, p₊f)),
      :s => Dtry(IrreversiblePort(entropy, s₊f))
    )
  )
end


osc_damped_flat = CompositeSystem(
  Dtry(
    :osc => Dtry(
      :q => Dtry(Junction(displacement, Position(1,2))),
    ),
    :p => Dtry(Junction(momentum, Position(1,4))),
    :s => Dtry(Junction(entropy, Position(2,5))),
  ),
  Dtry(
    :osc => Dtry(
      :pe => Dtry(
        InnerBox(
          Dtry(
            :q => Dtry(InnerPort(■.osc.q)),
          ),
          pe,
          Position(1,1)
        ),
      ),
      :ke => Dtry(
        InnerBox(
          Dtry(
            :p => Dtry(InnerPort(■.p)),
          ),
          ke,
          Position(1,5)
        ),
      ),
      :pkc => Dtry(
        InnerBox(
          Dtry(
            :q => Dtry(InnerPort(■.osc.q)),
            :p => Dtry(InnerPort(■.p))
          ),
          pkc,
          Position(1,3)
        ),
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :s => Dtry(InnerPort(■.s)),
        ),
        mf,
        Position(2,4)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        tc,
        Position(2,6)
      ),
    ),
  )
);

@test osc_damped_flat.isflat == true

@test assemble(osc_damped_flat) |> equations == Eq[
  Eq(FVar(■.osc.ke, ■.p), Add((Mul((Const(-1.0), Par(■.mf, ■.d, 0.02), XVar(■.osc.ke, ■.p), Pow(Par(■.osc.ke, ■.m, 1.0), Const(-1.0)))), Mul((Const(-1.0), Par(■.osc.pe, ■.k, 1.5), XVar(■.osc.pe, ■.q)))))),
  Eq(FVar(■.osc.pe, ■.q), Mul((XVar(■.osc.ke, ■.p), Pow(Par(■.osc.ke, ■.m, 1.0), Const(-1.0))))),
  Eq(FVar(■.tc, ■.s), Mul((Par(■.mf, ■.d, 0.02), Pow(XVar(■.osc.ke, ■.p), Const(2.0)), Pow(Par(■.osc.ke, ■.m, 1.0), Const(-2.0)), Pow(Par(■.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.tc, ■.s), Pow(Par(■.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.tc, ■.c₂, 2.0)))),
]

# 25.458 μs (573 allocations: 17.53 KiB) top-down approach
# 18.875 μs (480 allocations: 14.70 KiB) hybrid approach, 26% less runtime
# 12.875 μs (342 allocations: 10.98 KiB) recursive approach, 49% less runtime than top-down approach
# 44.750 μs (728 allocations: 25.83 KiB) two levels of nesting, state ports
# 54.333 μs (852 allocations: 30.59 KiB) arbitrary nesting of patterns
# 13.541 μs (328 allocations: 10.92 KiB) refactor Position, convenience constructors
# 23.708 μs (487 allocations: 15.66 KiB) components as values, dtry
# 24.167 μs (455 allocations: 15.48 KiB) DAESystem
# 83.542 μs (1343 allocations: 47.20 KiB) Symbolic differentiation (with simplification/normalization)
# @btime assemble($osc_damped_flat);

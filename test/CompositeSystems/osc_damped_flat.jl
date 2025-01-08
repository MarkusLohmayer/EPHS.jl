
tc = StorageComponent(
  Dtry(
    :s => Dtry(StoragePort(entropy, Const(1.) / Const(2.5) * exp(XVar(:s) / Const(2.5)) - θ₀))
  )
)

mf = IrreversibleComponent(
  Dtry(
    :p => Dtry(IrreversiblePort(momentum, Const(0.02) * EVar(:p))),
    :s => Dtry(IrreversiblePort(entropy, -((Const(0.02) * EVar(:p) * EVar(:p)) / (θ₀ + EVar(:s)))))
  )
)


osc_damped_flat = CompositeSystem(
  Dtry(
    :osc => Dtry(
      :q => Dtry(Junction(false, displacement, true, Position(1,2))),
    ),
    :p => Dtry(Junction(false, momentum, true, Position(1,4))),
    :s => Dtry(Junction(false, entropy, true, Position(2,5))),
  ),
  Dtry(
    :osc => Dtry(
      :pe => Dtry(
        InnerBox(
          Dtry(
            :q => Dtry(InnerPort(■.osc.q, true)),
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
            :q => Dtry(InnerPort(■.osc.q, true)),
            :p => Dtry(InnerPort(■.p, true))
          ),
          pkc,
          Position(1,3)
        ),
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p, true)),
          :s => Dtry(InnerPort(■.s, true)),
        ),
        mf,
        Position(2,4)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s, true)),
        ),
        tc,
        Position(2,6)
      ),
    ),
  )
);

@test osc_damped_flat.isflat == true

@test assemble(osc_damped_flat) |> equations == Eq[
  Eq(FVar(■.osc.pe, ■.q), Div(XVar(■.osc.ke, ■.p), Const(1.0))),
  Eq(FVar(■.osc.ke, ■.p), Add((Neg(Mul((Const(1.5), XVar(■.osc.pe, ■.q)))), Neg(Mul((Const(0.02), Div(XVar(■.osc.ke, ■.p), Const(1.0)))))))),
  Eq(FVar(■.tc, ■.s), Div(Mul((Const(0.02), Div(XVar(■.osc.ke, ■.p), Const(1.0)), Div(XVar(■.osc.ke, ■.p), Const(1.0)))), Mul((Div(Const(1.0), Const(2.5)), Exp(Div(XVar(■.tc, ■.s), Const(2.5)))))))
]

# 25.458 μs (573 allocations: 17.53 KiB) top-down approach
# 18.875 μs (480 allocations: 14.70 KiB) hybrid approach, 26% less runtime
# 12.875 μs (342 allocations: 10.98 KiB) recursive approach, 49% less runtime than top-down approach
# 44.750 μs (728 allocations: 25.83 KiB) two levels of nesting, state ports
# 54.333 μs (852 allocations: 30.59 KiB) arbitrary nesting of patterns
# 13.541 μs (328 allocations: 10.92 KiB) refactor Position, convenience constructors
# 23.708 μs (487 allocations: 15.66 KiB) components as values, dtry
# 24.167 μs (455 allocations: 15.48 KiB) DAESystem
# @btime assemble($osc_damped_flat);

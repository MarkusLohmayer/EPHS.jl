"""
Mechanical oscillator
"""
module TestOsc

using Test, EPHS


osc = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(displacement, Position(1, 2))),
    :p => Dtry(Junction(momentum, Position(1, 4), exposed=true)),
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
  )
)


@test assemble(osc) |> equations == Eq[
  Eq(FVar(■.ke, ■.p), Add((Mul((Const(-1.0), Par(■.pe, ■.k, 1.5), XVar(■.pe, ■.q))), FVar(■, ■.p)))),
  Eq(FVar(■.pe, ■.q), Mul((XVar(■.ke, ■.p), Pow(Par(■.ke, ■.m, 1.0), Const(-1.0)))))
]


@test relation(osc) == Relation(;
  storage=Dtry(
    :ke => Dtry(
      Dtry(
        :p => Dtry{SymExpr}(Add((FVar(■, ■.p), Mul((Const(-1.0), Par(■.pe, ■.k, 1.5), XVar(■.pe, ■.q))))))
      )
    ),
    :pe => Dtry(
      Dtry(
        :q => Dtry{SymExpr}(Mul((XVar(■.ke, ■.p), Pow(Par(■.ke, ■.m, 1.0), Const(-1.0)))))
      )
    )
  ),
  ports=Dtry(
    :p => Dtry(Port(
      StateProvider(XVar(■.ke, ■.p)),
      EffortProvider(Mul((XVar(■.ke, ■.p), Pow(Par(■.ke, ■.m, 1.0), Const(-1.0)))))
    ))
  )
)


# 7.812 μs (205 allocations: 6.52 KiB) top-down approach
# 6.400 μs (167 allocations: 5.53 KiB hybrid approach
# 6.008 μs (156 allocations: 5.25 KiB) recursive approach
# 25.166 μs (377 allocations: 13.55 KiB) two levels of nesting, state ports
# 28.750 μs (448 allocations: 16.25 KiB) arbitrary nesting of patterns
# 28.334 μs (431 allocations: 15.89 KiB)
# 7.021 μs (173 allocations: 5.95 KiB) isflat
# 7.052 μs (167 allocations: 5.78 KiB) refactor Position, convenience constructors
# 9.709 μs (196 allocations: 6.66 KiB) components as values, dtry
# 10.084 μs (200 allocations: 7.34 KiB) DAESystem
# 27.375 μs (490 allocations: 17.67 KiB) Symbolic differentiation (with simplification/normalization)
# @btime assemble($osc);


osc_damped_flat = CompositeSystem(
  Dtry(
    :osc => Dtry(
      :q => Dtry(Junction(displacement, Position(1, 2))),
    ),
    :p => Dtry(Junction(momentum, Position(1, 4))),
    :s => Dtry(Junction(entropy, Position(2, 5))),
  ),
  Dtry(
    :osc => Dtry(
      :pe => Dtry(
        InnerBox(
          Dtry(
            :q => Dtry(InnerPort(■.osc.q)),
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
            :q => Dtry(InnerPort(■.osc.q)),
            :p => Dtry(InnerPort(■.p))
          ),
          pkc,
          Position(1, 3)
        ),
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :s => Dtry(InnerPort(■.s)),
        ),
        linear_friction(d=0.02),
        Position(2, 4)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        thermal_capacity(c₁=1.0, c₂=2.0),
        Position(2, 6)
      ),
    ),
  )
)


@test osc_damped_flat.isflat == true


@test assemble(osc_damped_flat) |> equations == Eq[
  Eq(FVar(■.osc.ke, ■.p), Add((Mul((Const(-1.0), Par(■.mf, ■.d, 0.02), XVar(■.osc.ke, ■.p), Pow(Par(■.osc.ke, ■.m, 1.0), Const(-1.0)))), Mul((Const(-1.0), Par(■.osc.pe, ■.k, 1.5), XVar(■.osc.pe, ■.q)))))),
  Eq(FVar(■.osc.pe, ■.q), Mul((XVar(■.osc.ke, ■.p), Pow(Par(■.osc.ke, ■.m, 1.0), Const(-1.0))))),
  Eq(FVar(■.tc, ■.s), Mul((Par(■.mf, ■.d, 0.02), Pow(XVar(■.osc.ke, ■.p), Const(2.0)), Pow(Par(■.osc.ke, ■.m, 1.0), Const(-2.0)), Pow(Par(■.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.tc, ■.s), Pow(Par(■.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.tc, ■.c₂, 2.0)))),
]


@test relation(osc_damped_flat) == Relation(;
  storage=Dtry(
    :osc => Dtry(
      :ke => Dtry(
        Dtry(
          :p => Dtry{SymExpr}(Add((Mul((Const(-1.0), Par(■.mf, ■.d, 0.02), XVar(■.osc.ke, ■.p), Pow(Par(■.osc.ke, ■.m, 1.0), Const(-1.0)))), Mul((Const(-1.0), Par(■.osc.pe, ■.k, 1.5), XVar(■.osc.pe, ■.q))))))
        )
      ),
      :pe => Dtry(
        Dtry(
          :q => Dtry{SymExpr}(Mul((XVar(■.osc.ke, ■.p), Pow(Par(■.osc.ke, ■.m, 1.0), Const(-1.0)))))
        )
      )
    ),
    :tc => Dtry(
      Dtry(
        :s => Dtry{SymExpr}(Mul((Par(■.mf, ■.d, 0.02), Pow(XVar(■.osc.ke, ■.p), Const(2.0)), Pow(Par(■.osc.ke, ■.m, 1.0), Const(-2.0)), Pow(Par(■.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.tc, ■.s), Pow(Par(■.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.tc, ■.c₂, 2.0))))
      )
    )
  )
)


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


osc_damped_nested = CompositeSystem(
  Dtry(
    :p => Dtry(Junction(momentum, Position(1, 2))),
    :s => Dtry(Junction(entropy, Position(1, 4))),
  ),
  Dtry(
    :osc => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        osc,
        Position(1, 1)
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :s => Dtry(InnerPort(■.s)),
        ),
        linear_friction(d=0.02),
        Position(1, 3)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        thermal_capacity(c₁=1.0, c₂=2.0),
        Position(1, 5)
      ),
    ),
  )
)


@test osc_damped_nested.isflat == false


@test flatten(osc_damped_nested) == CompositeSystem{Nothing}(osc_damped_flat)
@test assemble(osc_damped_nested) == assemble(osc_damped_flat)
@test relation(osc_damped_nested) == relation(osc_damped_flat)


# 50.625 μs (781 allocations: 27.59 KiB) two levels of nesting
# 85.041 μs (1265 allocations: 45.20 KiB) arbitrary nesting of patterns
# 59.625 μs (949 allocations: 33.41 KiB) isflat
# 57.958 μs (891 allocations: 31.30 KiB) refactor Position, convenience constructors
# 67.375 μs (1050 allocations: 35.80 KiB) components as values, dtry
# 68.041 μs (1018 allocations: 35.72 KiB) DAESystem
# 137.625 μs (1973 allocations: 70.14 KiB) Symbolic differentiation (with simplification/normalization)
# @btime assemble($osc_damped_nested);

end

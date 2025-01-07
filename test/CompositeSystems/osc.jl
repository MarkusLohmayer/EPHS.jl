# mechanical oscillator

pe = let
  k = Par(:k, 1.5)
  q = XVar(:q)
  E = Const(1/2) * k * q^Const(2)
  StorageComponent(
    Dtry(
      :q => Dtry(displacement)
    ),
    E
  )
end;

ke = let
  m = Par(:m, 1.)
  p = XVar(:p)
  E = Const(1/2) * p^Const(2) / m
  StorageComponent(
    Dtry(
      :p => Dtry(momentum)
    ),
    E
  )
end;

pkc = ReversibleComponent(
  Dtry(
    :q => Dtry(ReversiblePort(FlowPort(displacement, -EVar(:p)))),
    :p => Dtry(ReversiblePort(FlowPort(momentum, EVar(:q))))
  )
);

osc = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(displacement, Position(1,2))),
    :p => Dtry(Junction(momentum, Position(1,4), exposed=true)),
  ),
  Dtry(
    :pe => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
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
          :q => Dtry(InnerPort(■.q)),
          :p => Dtry(InnerPort(■.p))
        ),
        pkc,
        Position(1,3)
      ),
    ),
  )
);

@test assemble(osc) |> equations == Eq[
  Eq(FVar(■.ke, ■.p), Add((Mul((Const(-1.0), Par(■.pe, ■.k, 1.5), XVar(■.pe, ■.q))), FVar(■, ■.p)))),
  Eq(FVar(■.pe, ■.q), Mul((XVar(■.ke, ■.p), Pow(Par(■.ke, ■.m, 1.0), Const(-1.0)))))
]


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

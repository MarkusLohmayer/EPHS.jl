"""
DC shunt motor
"""
module TestMotor

using Test, EPHS


stator = CompositeSystem(
  Dtry(
    :b => Dtry(Junction(magnetic_flux, Position(2, 3), exposed=true, power=false)),
    :q => Dtry(Junction(charge, Position(2, 1), exposed=true)),
    :s => Dtry(Junction(entropy, Position(2, 5))),
  ),
  Dtry(
    :emc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
          :b => Dtry(InnerPort(■.b)),
        ),
        emc,
        Position(2, 2)
      ),
    ),
    :coil => Dtry(
      InnerBox(
        Dtry(
          :b => Dtry(InnerPort(■.b)),
        ),
        linear_inductor(l=1.0),
        Position(1, 3)
      ),
    ),
    :res => Dtry(
      InnerBox(
        Dtry(
          :b => Dtry(InnerPort(■.b)),
          :s => Dtry(InnerPort(■.s))
        ),
        magnetic_resistor(r=0.01),
        Position(2, 4)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s))
        ),
        thermal_capacity(c₁=1.0, c₂=2.0),
        Position(1, 5)
      ),
    ),
  )
)

@test assemble(stator) |> equations == Eq[
  Eq(FVar(■.coil, ■.b), Add((EVar(■, ■.q), Mul((Const(-1.0), Par(■.res, ■.r, 0.01), XVar(■.coil, ■.b), Pow(Par(■.coil, ■.l, 1.0), Const(-1.0))))))),
  Eq(FVar(■.tc, ■.s), Mul((Par(■.res, ■.r, 0.01), Pow(XVar(■.coil, ■.b), Const(2.0)), Pow(Par(■.coil, ■.l, 1.0), Const(-2.0)), Pow(Par(■.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.tc, ■.s), Pow(Par(■.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.tc, ■.c₂, 2.0)))),
]


rotor = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(charge, Position(2, 1), exposed=true)),
    :b => Dtry(Junction(magnetic_flux, Position(2, 3))),
    :bₛ => Dtry(Junction(magnetic_flux, Position(1, 4), exposed=true, power=false)),
    :p => Dtry(Junction(angular_momentum, Position(2, 5), exposed=true)),
    :s => Dtry(Junction(entropy, Position(3, 4))),
  ),
  Dtry(
    :emc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
          :b => Dtry(InnerPort(■.b)),
        ),
        emc,
        Position(2, 2)
      ),
    ),
    :coil => Dtry(
      InnerBox(
        Dtry(
          :b => Dtry(InnerPort(■.b)),
        ),
        linear_inductor(l=1.0),
        Position(1, 3)
      ),
    ),
    :mkc => Dtry(
      InnerBox(
        Dtry(
          :b => Dtry(InnerPort(■.b)),
          :p => Dtry(InnerPort(■.p)),
          :bₛ => Dtry(InnerPort(■.bₛ, power=false)),
        ),
        mkc,
        Position(2, 4)
      ),
    ),
    :mass => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        angular_mass(m=1.0),
        Position(1, 5)
      ),
    ),
    :res => Dtry(
      InnerBox(
        Dtry(
          :b => Dtry(InnerPort(■.b)),
          :s => Dtry(InnerPort(■.s))
        ),
        magnetic_resistor(r=0.01),
        Position(3, 3)
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :s => Dtry(InnerPort(■.s))
        ),
        rotational_friction(d=0.01),
        Position(3, 5)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s))
        ),
        thermal_capacity(c₁=1.0, c₂=2.0),
        Position(4, 4)
      ),
    ),
  )
)


motor = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(charge, Position(2, 1), exposed=true)),
    :bₛ => Dtry(Junction(magnetic_flux, Position(2, 2), power=false)),
    :p => Dtry(Junction(angular_momentum, Position(3, 3), exposed=true)),
  ),
  Dtry(
    :stator => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
          :b => Dtry(InnerPort(■.bₛ, power=false)),
        ),
        stator,
        Position(1, 2)
      ),
    ),
    :rotor => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
          :bₛ => Dtry(InnerPort(■.bₛ, power=false)),
          :p => Dtry(InnerPort(■.p)),
        ),
        rotor,
        Position(3, 2)
      ),
    ),
  )
)

@test assemble(motor) |> equations == Eq[
  Eq(FVar(■.rotor.coil, ■.b), Add((EVar(■, ■.q), Mul((Const(-1.0), XVar(■.stator.coil, ■.b), XVar(■.rotor.mass, ■.p), Pow(Par(■.rotor.mass, ■.m, 1.0), Const(-1.0)))), Mul((Const(-1.0), Par(■.rotor.res, ■.r, 0.01), XVar(■.rotor.coil, ■.b), Pow(Par(■.rotor.coil, ■.l, 1.0), Const(-1.0))))))),
  Eq(FVar(■.rotor.mass, ■.p), Add((Mul((Const(-1.0), Par(■.rotor.mf, ■.d, 0.01), XVar(■.rotor.mass, ■.p), Pow(Par(■.rotor.mass, ■.m, 1.0), Const(-1.0)))), Mul((XVar(■.stator.coil, ■.b), XVar(■.rotor.coil, ■.b), Pow(Par(■.rotor.coil, ■.l, 1.0), Const(-1.0)))), FVar(■, ■.p)))),
  Eq(FVar(■.rotor.tc, ■.s), Add((Mul((Par(■.rotor.mf, ■.d, 0.01), Pow(XVar(■.rotor.mass, ■.p), Const(2.0)), Pow(Par(■.rotor.mass, ■.m, 1.0), Const(-2.0)), Pow(Par(■.rotor.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.rotor.tc, ■.s), Pow(Par(■.rotor.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.rotor.tc, ■.c₂, 2.0))), Mul((Par(■.rotor.res, ■.r, 0.01), Pow(XVar(■.rotor.coil, ■.b), Const(2.0)), Pow(Par(■.rotor.coil, ■.l, 1.0), Const(-2.0)), Pow(Par(■.rotor.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.rotor.tc, ■.s), Pow(Par(■.rotor.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.rotor.tc, ■.c₂, 2.0)))))),
  Eq(FVar(■.stator.coil, ■.b), Add((EVar(■, ■.q), Mul((Const(-1.0), Par(■.stator.res, ■.r, 0.01), XVar(■.stator.coil, ■.b), Pow(Par(■.stator.coil, ■.l, 1.0), Const(-1.0))))))),
  Eq(FVar(■.stator.tc, ■.s), Mul((Par(■.stator.res, ■.r, 0.01), Pow(XVar(■.stator.coil, ■.b), Const(2.0)), Pow(Par(■.stator.coil, ■.l, 1.0), Const(-2.0)), Pow(Par(■.stator.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.stator.tc, ■.s), Pow(Par(■.stator.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.stator.tc, ■.c₂, 2.0)))),
]


load = CompositeSystem(
  Dtry(
    :p => Dtry(Junction(angular_momentum, Position(1, 1), exposed=true)),
    :s => Dtry(Junction(entropy, Position(1, 3))),
  ),
  Dtry(
    :res => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :s => Dtry(InnerPort(■.s)),
        ),
        rotational_friction(d=0.01),
        Position(1, 2)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        thermal_capacity(c₁=1.0, c₂=2.0),
        Position(1, 4)
      ),
    ),
  )
)


motor_rig = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(charge, Position(1, 1), exposed=true)),
    :p => Dtry(Junction(angular_momentum, Position(1, 3))),
  ),
  Dtry(
    :motor => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
          :p => Dtry(InnerPort(■.p)),
        ),
        motor,
        Position(1, 2)
      ),
    ),
    :load => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        load,
        Position(1, 4)
      ),
    ),
  )
)

assemble(motor_rig)

# 377.000 μs (5460 allocations: 199.62 KiB) arbitrary nesting of patterns
# 318.042 μs (4633 allocations: 172.94 KiB) check=false
# 236.334 μs (3609 allocations: 129.45 KiB) isflat
# 216.250 μs (3320 allocations: 119.23 KiB) refactor Position, convenience constructors
# 249.166 μs (3885 allocations: 135.36 KiB) components as values, dtry
# 247.542 μs (3715 allocations: 132.47 KiB) DAESystem
# 524.459 μs (7382 allocations: 262.09 KiB) Symbolic differentiation (with simplification/normalization)
# @btime assemble($motor_rig);

end

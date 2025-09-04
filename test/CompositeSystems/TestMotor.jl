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


@test relation(stator) == Relation(;
  storage=Dtry(
    :coil => Dtry(
      Dtry(
        :b => Dtry{SymExpr}(Add((EVar(■, ■.q), Mul((Const(-1.0), Par(■.res, ■.r, 0.01), XVar(■.coil, ■.b), Pow(Par(■.coil, ■.l, 1.0), Const(-1.0)))))))
      )
    ),
    :tc => Dtry(
      Dtry(
        :s => Dtry{SymExpr}(Mul((Par(■.res, ■.r, 0.01), Pow(XVar(■.coil, ■.b), Const(2.0)), Pow(Par(■.coil, ■.l, 1.0), Const(-2.0)), Pow(Par(■.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.tc, ■.s), Pow(Par(■.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.tc, ■.c₂, 2.0))))
      )
    )
  ),
  ports=Dtry(
    :b => Dtry(Port(
      StateProvider(XVar(■.coil, ■.b)),
    )),
    :q => Dtry(Port(
      FlowProvider(Mul((XVar(■.coil, ■.b), Pow(Par(■.coil, ■.l, 1.0), Const(-1.0)))))
    ))
  )
)


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


@test relation(rotor) == Relation(;
  storage=Dtry(
    :coil => Dtry(
      Dtry(
        :b => Dtry{SymExpr}(Add((EVar(■, ■.q), Mul((Const(-1.0), XVar(■, ■.bₛ), XVar(■.mass, ■.p), Pow(Par(■.mass, ■.m, 1.0), Const(-1.0)))), Mul((Const(-1.0), Par(■.res, ■.r, 0.01), XVar(■.coil, ■.b), Pow(Par(■.coil, ■.l, 1.0), Const(-1.0)))))))
      )
    ),
    :mass => Dtry(
      Dtry(
        :p => Dtry{SymExpr}(Add((FVar(■, ■.p), Mul((Const(-1.0), Par(■.mf, ■.d, 0.01), XVar(■.mass, ■.p), Pow(Par(■.mass, ■.m, 1.0), Const(-1.0)))), Mul((XVar(■, ■.bₛ), XVar(■.coil, ■.b), Pow(Par(■.coil, ■.l, 1.0), Const(-1.0)))))))
      )
    ),
    :tc => Dtry(
      Dtry(
        :s => Dtry{SymExpr}(Add((Mul((Par(■.mf, ■.d, 0.01), Pow(XVar(■.mass, ■.p), Const(2.0)), Pow(Par(■.mass, ■.m, 1.0), Const(-2.0)), Pow(Par(■.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.tc, ■.s), Pow(Par(■.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.tc, ■.c₂, 2.0))), Mul((Par(■.res, ■.r, 0.01), Pow(XVar(■.coil, ■.b), Const(2.0)), Pow(Par(■.coil, ■.l, 1.0), Const(-2.0)), Pow(Par(■.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.tc, ■.s), Pow(Par(■.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.tc, ■.c₂, 2.0))))))
      )
    )
  ),
  ports=Dtry(
    :bₛ => Dtry(Port(StateConsumer())),
    :p => Dtry(
      Port(
        StateProvider(XVar(■.mass, ■.p)),
        EffortProvider(Mul((XVar(■.mass, ■.p), Pow(Par(■.mass, ■.m, 1.0), Const(-1.0)))))
      )
    ),
    :q => Dtry(Port(FlowProvider(Mul((XVar(■.coil, ■.b), Pow(Par(■.coil, ■.l, 1.0), Const(-1.0)))))))
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


@test relation(motor) == Relation(;
  storage=Dtry(
    :rotor => Dtry(
      :coil => Dtry(
        Dtry(
          :b => Dtry{SymExpr}(Add((EVar(■, ■.q), Mul((Const(-1.0), XVar(■.stator.coil, ■.b), XVar(■.rotor.mass, ■.p), Pow(Par(■.rotor.mass, ■.m, 1.0), Const(-1.0)))), Mul((Const(-1.0), Par(■.rotor.res, ■.r, 0.01), XVar(■.rotor.coil, ■.b), Pow(Par(■.rotor.coil, ■.l, 1.0), Const(-1.0)))))))
        )
      ),
      :mass => Dtry(
        Dtry(
          :p => Dtry{SymExpr}(Add((FVar(■, ■.p), Mul((Const(-1.0), Par(■.rotor.mf, ■.d, 0.01), XVar(■.rotor.mass, ■.p), Pow(Par(■.rotor.mass, ■.m, 1.0), Const(-1.0)))), Mul((XVar(■.stator.coil, ■.b), XVar(■.rotor.coil, ■.b), Pow(Par(■.rotor.coil, ■.l, 1.0), Const(-1.0)))))))
        )
      ),
      :tc => Dtry(
        Dtry(
          :s => Dtry{SymExpr}(Add((Mul((Par(■.rotor.mf, ■.d, 0.01), Pow(XVar(■.rotor.mass, ■.p), Const(2.0)), Pow(Par(■.rotor.mass, ■.m, 1.0), Const(-2.0)), Pow(Par(■.rotor.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.rotor.tc, ■.s), Pow(Par(■.rotor.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.rotor.tc, ■.c₂, 2.0))), Mul((Par(■.rotor.res, ■.r, 0.01), Pow(XVar(■.rotor.coil, ■.b), Const(2.0)), Pow(Par(■.rotor.coil, ■.l, 1.0), Const(-2.0)), Pow(Par(■.rotor.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.rotor.tc, ■.s), Pow(Par(■.rotor.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.rotor.tc, ■.c₂, 2.0))))))
        )
      )
    ),
    :stator => Dtry(
      :coil => Dtry(Dtry(
        :b => Dtry{SymExpr}(Add((EVar(■, ■.q), Mul((Const(-1.0), Par(■.stator.res, ■.r, 0.01), XVar(■.stator.coil, ■.b), Pow(Par(■.stator.coil, ■.l, 1.0), Const(-1.0)))))))
      )),
      :tc => Dtry(Dtry(
        :s => Dtry{SymExpr}(Mul((Par(■.stator.res, ■.r, 0.01), Pow(XVar(■.stator.coil, ■.b), Const(2.0)), Pow(Par(■.stator.coil, ■.l, 1.0), Const(-2.0)), Pow(Par(■.stator.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.stator.tc, ■.s), Pow(Par(■.stator.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.stator.tc, ■.c₂, 2.0))))
      ))
    )
  ),
  ports=Dtry(
    :p => Dtry(
      Port(
        StateProvider(XVar(■.rotor.mass, ■.p)),
        EffortProvider(Mul((XVar(■.rotor.mass, ■.p), Pow(Par(■.rotor.mass, ■.m, 1.0), Const(-1.0)))))
      )
    ),
    :q => Dtry(
      Port(
        FlowProvider(Add((Mul((XVar(■.rotor.coil, ■.b), Pow(Par(■.rotor.coil, ■.l, 1.0), Const(-1.0)))), Mul((XVar(■.stator.coil, ■.b), Pow(Par(■.stator.coil, ■.l, 1.0), Const(-1.0)))))))
      )
    )
  )
)


motor_flat = CompositeSystem(
  Dtry(
    :bₛ => Dtry(Junction(magnetic_flux, Position(2, 3), power=false)),
    :p => Dtry(Junction(angular_momentum, Position(5, 4), exposed=true)),
    :q => Dtry(Junction(charge, Position(2, 1), exposed=true)),
    :rotor => Dtry(
      :b => Dtry(Junction(magnetic_flux, Position(5, 2))),
      :s => Dtry(Junction(entropy, Position(6, 3)))
    ),
    :stator => Dtry(
      :s => Dtry(Junction(entropy, Position(2, 5)))
    )
  ),
  Dtry(
    :stator => Dtry(
      :emc => Dtry(
        InnerBox(
          Dtry(
            :q => Dtry(InnerPort(■.q)),
            :b => Dtry(InnerPort(■.bₛ)),
          ),
          emc,
          Position(2, 2)
        ),
      ),
      :coil => Dtry(
        InnerBox(
          Dtry(
            :b => Dtry(InnerPort(■.bₛ)),
          ),
          linear_inductor(l=1.0),
          Position(1, 3)
        ),
      ),
      :res => Dtry(
        InnerBox(
          Dtry(
            :b => Dtry(InnerPort(■.bₛ)),
            :s => Dtry(InnerPort(■.stator.s))
          ),
          magnetic_resistor(r=0.01),
          Position(2, 4)
        ),
      ),
      :tc => Dtry(
        InnerBox(
          Dtry(
            :s => Dtry(InnerPort(■.stator.s))
          ),
					thermal_capacity(c₁=1.0, c₂=2.0),
          Position(1, 5)
        ),
      ),
    ),
    :rotor => Dtry(
      :emc => Dtry(
        InnerBox(
          Dtry(
            :q => Dtry(InnerPort(■.q)),
            :b => Dtry(InnerPort(■.rotor.b)),
          ),
          emc,
          Position(5, 1)
        ),
      ),
      :coil => Dtry(
        InnerBox(
          Dtry(
            :b => Dtry(InnerPort(■.rotor.b)),
          ),
          linear_inductor(l=1.0),
          Position(4, 2)
        ),
      ),
      :mkc => Dtry(
        InnerBox(
          Dtry(
            :b => Dtry(InnerPort(■.rotor.b)),
            :p => Dtry(InnerPort(■.p)),
            :bₛ => Dtry(InnerPort(■.bₛ, power=false)),
          ),
          mkc,
          Position(5, 3)
        ),
      ),
      :mass => Dtry(
        InnerBox(
          Dtry(
            :p => Dtry(InnerPort(■.p)),
          ),
					angular_mass(m=1.0),
          Position(4, 4)
        ),
      ),
      :res => Dtry(
        InnerBox(
          Dtry(
            :b => Dtry(InnerPort(■.rotor.b)),
            :s => Dtry(InnerPort(■.rotor.s))
          ),
          magnetic_resistor(r=0.01),
          Position(6, 2)
        ),
      ),
      :mf => Dtry(
        InnerBox(
          Dtry(
            :p => Dtry(InnerPort(■.p)),
            :s => Dtry(InnerPort(■.rotor.s))
          ),
          rotational_friction(d=0.01),
          Position(6, 4)
        ),
      ),
      :tc => Dtry(
        InnerBox(
          Dtry(
            :s => Dtry(InnerPort(■.rotor.s))
          ),
					thermal_capacity(c₁=1.0, c₂=2.0),
          Position(7, 3)
        ),
      )
    ),
  )
)


@test flatten(motor) == CompositeSystem{Nothing}(motor_flat)
@test assemble(motor) == assemble(motor_flat)
@test relation(motor) == relation(motor_flat)


# TODO add flywheel and connect piston with crank mechanism


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


@test assemble(motor_rig) |> equations == Eq[
  Eq(FVar(■.load.tc, ■.s), Mul((Par(■.load.res, ■.d, 0.01), Pow(XVar(■.motor.rotor.mass, ■.p), Const(2.0)), Pow(Par(■.motor.rotor.mass, ■.m, 1.0), Const(-2.0)), Pow(Par(■.load.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.load.tc, ■.s), Pow(Par(■.load.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.load.tc, ■.c₂, 2.0)))),
  Eq(FVar(■.motor.rotor.coil, ■.b), Add((EVar(■, ■.q), Mul((Const(-1.0), XVar(■.motor.stator.coil, ■.b), XVar(■.motor.rotor.mass, ■.p), Pow(Par(■.motor.rotor.mass, ■.m, 1.0), Const(-1.0)))), Mul((Const(-1.0), Par(■.motor.rotor.res, ■.r, 0.01), XVar(■.motor.rotor.coil, ■.b), Pow(Par(■.motor.rotor.coil, ■.l, 1.0), Const(-1.0))))))),
  Eq(FVar(■.motor.rotor.mass, ■.p), Add((Mul((Const(-1.0), Par(■.load.res, ■.d, 0.01), XVar(■.motor.rotor.mass, ■.p), Pow(Par(■.motor.rotor.mass, ■.m, 1.0), Const(-1.0)))), Mul((Const(-1.0), Par(■.motor.rotor.mf, ■.d, 0.01), XVar(■.motor.rotor.mass, ■.p), Pow(Par(■.motor.rotor.mass, ■.m, 1.0), Const(-1.0)))), Mul((XVar(■.motor.stator.coil, ■.b), XVar(■.motor.rotor.coil, ■.b), Pow(Par(■.motor.rotor.coil, ■.l, 1.0), Const(-1.0))))))),
  Eq(FVar(■.motor.rotor.tc, ■.s), Add((Mul((Par(■.motor.rotor.mf, ■.d, 0.01), Pow(XVar(■.motor.rotor.mass, ■.p), Const(2.0)), Pow(Par(■.motor.rotor.mass, ■.m, 1.0), Const(-2.0)), Pow(Par(■.motor.rotor.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.motor.rotor.tc, ■.s), Pow(Par(■.motor.rotor.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.motor.rotor.tc, ■.c₂, 2.0))), Mul((Par(■.motor.rotor.res, ■.r, 0.01), Pow(XVar(■.motor.rotor.coil, ■.b), Const(2.0)), Pow(Par(■.motor.rotor.coil, ■.l, 1.0), Const(-2.0)), Pow(Par(■.motor.rotor.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.motor.rotor.tc, ■.s), Pow(Par(■.motor.rotor.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.motor.rotor.tc, ■.c₂, 2.0)))))),
  Eq(FVar(■.motor.stator.coil, ■.b), Add((EVar(■, ■.q), Mul((Const(-1.0), Par(■.motor.stator.res, ■.r, 0.01), XVar(■.motor.stator.coil, ■.b), Pow(Par(■.motor.stator.coil, ■.l, 1.0), Const(-1.0))))))),
  Eq(FVar(■.motor.stator.tc, ■.s), Mul((Par(■.motor.stator.res, ■.r, 0.01), Pow(XVar(■.motor.stator.coil, ■.b), Const(2.0)), Pow(Par(■.motor.stator.coil, ■.l, 1.0), Const(-2.0)), Pow(Par(■.motor.stator.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.motor.stator.tc, ■.s), Pow(Par(■.motor.stator.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.motor.stator.tc, ■.c₂, 2.0))))
]


@test relation(motor_rig) == Relation(;
  storage=Dtry(
    :load => Dtry(
      :tc => Dtry(
        Dtry(
          :s => Dtry{SymExpr}(Mul((Par(■.load.res, ■.d, 0.01), Pow(XVar(■.motor.rotor.mass, ■.p), Const(2.0)), Pow(Par(■.motor.rotor.mass, ■.m, 1.0), Const(-2.0)), Pow(Par(■.load.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.load.tc, ■.s), Pow(Par(■.load.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.load.tc, ■.c₂, 2.0))))
        )
      )
    ),
    :motor => Dtry(
      :rotor => Dtry(
        :coil => Dtry(
          Dtry(
            :b => Dtry{SymExpr}(Add((EVar(■, ■.q), Mul((Const(-1.0), XVar(■.motor.stator.coil, ■.b), XVar(■.motor.rotor.mass, ■.p), Pow(Par(■.motor.rotor.mass, ■.m, 1.0), Const(-1.0)))), Mul((Const(-1.0), Par(■.motor.rotor.res, ■.r, 0.01), XVar(■.motor.rotor.coil, ■.b), Pow(Par(■.motor.rotor.coil, ■.l, 1.0), Const(-1.0)))))))
          )
        ),
        :mass => Dtry(
          Dtry(
            :p => Dtry{SymExpr}(Add((Mul((Const(-1.0), Par(■.load.res, ■.d, 0.01), XVar(■.motor.rotor.mass, ■.p), Pow(Par(■.motor.rotor.mass, ■.m, 1.0), Const(-1.0)))), Mul((Const(-1.0), Par(■.motor.rotor.mf, ■.d, 0.01), XVar(■.motor.rotor.mass, ■.p), Pow(Par(■.motor.rotor.mass, ■.m, 1.0), Const(-1.0)))), Mul((XVar(■.motor.stator.coil, ■.b), XVar(■.motor.rotor.coil, ■.b), Pow(Par(■.motor.rotor.coil, ■.l, 1.0), Const(-1.0)))))))
          )
        ),
        :tc => Dtry(
          Dtry(
            :s => Dtry{SymExpr}(Add((Mul((Par(■.motor.rotor.mf, ■.d, 0.01), Pow(XVar(■.motor.rotor.mass, ■.p), Const(2.0)), Pow(Par(■.motor.rotor.mass, ■.m, 1.0), Const(-2.0)), Pow(Par(■.motor.rotor.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.motor.rotor.tc, ■.s), Pow(Par(■.motor.rotor.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.motor.rotor.tc, ■.c₂, 2.0))), Mul((Par(■.motor.rotor.res, ■.r, 0.01), Pow(XVar(■.motor.rotor.coil, ■.b), Const(2.0)), Pow(Par(■.motor.rotor.coil, ■.l, 1.0), Const(-2.0)), Pow(Par(■.motor.rotor.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.motor.rotor.tc, ■.s), Pow(Par(■.motor.rotor.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.motor.rotor.tc, ■.c₂, 2.0))))))
          )
        )
      ),
      :stator => Dtry(
        :coil => Dtry(
          Dtry(
            :b => Dtry{SymExpr}(Add((EVar(■, ■.q), Mul((Const(-1.0), Par(■.motor.stator.res, ■.r, 0.01), XVar(■.motor.stator.coil, ■.b), Pow(Par(■.motor.stator.coil, ■.l, 1.0), Const(-1.0)))))))
          )
        ),
        :tc => Dtry(
          Dtry(
            :s => Dtry{SymExpr}(Mul((Par(■.motor.stator.res, ■.r, 0.01), Pow(XVar(■.motor.stator.coil, ■.b), Const(2.0)), Pow(Par(■.motor.stator.coil, ■.l, 1.0), Const(-2.0)), Pow(Par(■.motor.stator.tc, ■.c₁, 1.0), Const(-1.0)), Pow(Exp(Mul((XVar(■.motor.stator.tc, ■.s), Pow(Par(■.motor.stator.tc, ■.c₂, 2.0), Const(-1.0))))), Const(-1.0)), Par(■.motor.stator.tc, ■.c₂, 2.0))))
          )
        )
      )
    )
  ),
  ports=Dtry(
    :q => Dtry(Port(FlowProvider(Add((Mul((XVar(■.motor.rotor.coil, ■.b), Pow(Par(■.motor.rotor.coil, ■.l, 1.0), Const(-1.0)))), Mul((XVar(■.motor.stator.coil, ■.b), Pow(Par(■.motor.stator.coil, ■.l, 1.0), Const(-1.0)))))))))
  )
)


# 377.000 μs (5460 allocations: 199.62 KiB) arbitrary nesting of patterns
# 318.042 μs (4633 allocations: 172.94 KiB) check=false
# 236.334 μs (3609 allocations: 129.45 KiB) isflat
# 216.250 μs (3320 allocations: 119.23 KiB) refactor Position, convenience constructors
# 249.166 μs (3885 allocations: 135.36 KiB) components as values, dtry
# 247.542 μs (3715 allocations: 132.47 KiB) DAESystem
# 524.459 μs (7382 allocations: 262.09 KiB) Symbolic differentiation (with simplification/normalization)
# 411.292 μs (6989 allocations: 249.14 KiB) Relation
# @btime assemble($motor_rig);


# 879.667 μs (15580 allocations: 547.73 KiB) Relation
# @btime relation($motor_rig);

end

# DC shunt motor

## stator

coil = StorageComponent(
  Dtry(
    :b => Dtry(StoragePort(magnetic_flux, XVar(:b) / Const(1.)))
  )
)

emc = ReversibleComponent(
  Dtry(
    :q => Dtry(ReversiblePort(FlowPort(charge, EVar(:b)))),
    :b => Dtry(ReversiblePort(FlowPort(magnetic_flux, -EVar(:q))))
  )
)

res = IrreversibleComponent(
  Dtry(
    :b => Dtry(IrreversiblePort(magnetic_flux, Const(0.01) * EVar(:b))),
    :s => Dtry(IrreversiblePort(entropy, -((Const(0.01) * EVar(:b) * EVar(:b)) / (θ₀ + EVar(:s)))))
  )
)

stator = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(true, charge, true, Position(2,1))),
    :b => Dtry(Junction(true, magnetic_flux, false, Position(2,3))),
    :s => Dtry(Junction(false, entropy, true, Position(2,5))),
  ),
  Dtry(
    :emc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q, true)),
          :b => Dtry(InnerPort(■.b, true)),
        ),
        emc,
        Position(2,2)
      ),
    ),
    :coil => Dtry(
      InnerBox(
        Dtry(
          :b => Dtry(InnerPort(■.b, true)),
        ),
        coil,
        Position(1,3)
      ),
    ),
    :res => Dtry(
      InnerBox(
        Dtry(
          :b => Dtry(InnerPort(■.b, true)),
          :s => Dtry(InnerPort(■.s, true))
        ),
        res,
        Position(2,4)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s, true))
        ),
        tc,
        Position(1,5)
      ),
    ),
  )
);

@test assemble(stator) == Eq[
  Eq(FVar(■.coil, ■.b), Neg(Add((Neg(EVar(■, ■.q)), Mul((Const(0.01), Div(XVar(■.coil, ■.b), Const(1.0))))))))
  Eq(FVar(■.tc, ■.s), Div(Mul((Const(0.01), Div(XVar(■.coil, ■.b), Const(1.0)), Div(XVar(■.coil, ■.b), Const(1.0)))), Mul((Div(Const(1.0), Const(2.5)), Exp(Div(XVar(■.tc, ■.s), Const(2.5)))))))
]


## rotor

angular_mass = StorageComponent(
  Dtry(
    :p => Dtry(StoragePort(angular_momentum, XVar(:p) / Const(1.)))
  )
)

mkc = ReversibleComponent(
  Dtry(
    :b => Dtry(ReversiblePort(FlowPort(magnetic_flux, XVar(:bₛ) * EVar(:p)))),
    :p => Dtry(ReversiblePort(FlowPort(angular_momentum, -(XVar(:bₛ) * EVar(:b))))),
    :bₛ => Dtry(ReversiblePort(StatePort(magnetic_flux)))
  )
)

rotational_friction = IrreversibleComponent(
  Dtry(
    :p => Dtry(IrreversiblePort(angular_momentum, Const(0.01) * EVar(:p))),
    :s => Dtry(IrreversiblePort(entropy, -((Const(0.01) * EVar(:p) * EVar(:p)) / (θ₀ + EVar(:s)))))
  )
)

rotor = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(true, charge, true, Position(1,2))),
    :b => Dtry(Junction(false, magnetic_flux, false, Position(2,3))),
    :bₛ => Dtry(Junction(true, magnetic_flux, false, Position(1,4))),
    :p => Dtry(Junction(true, angular_momentum, true, Position(2,5))),
    :s => Dtry(Junction(false, entropy, true, Position(3,4))),
  ),
  Dtry(
    :emc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q, true)),
          :b => Dtry(InnerPort(■.b, true)),
        ),
        emc,
        Position(2,2)
      ),
    ),
    :coil => Dtry(
      InnerBox(
        Dtry(
          :b => Dtry(InnerPort(■.b, true)),
        ),
        coil,
        Position(1,3)
      ),
    ),
    :mkc => Dtry(
      InnerBox(
        Dtry(
          :b => Dtry(InnerPort(■.b, true)),
          :p => Dtry(InnerPort(■.p, true)),
          :bₛ => Dtry(InnerPort(■.bₛ, false)),
        ),
        mkc,
        Position(2,4)
      ),
    ),
    :mass => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p, true)),
        ),
        angular_mass,
        Position(1,5)
      ),
    ),
    :res => Dtry(
      InnerBox(
        Dtry(
          :b => Dtry(InnerPort(■.b, true)),
          :s => Dtry(InnerPort(■.s, true))
        ),
        res,
        Position(3,3)
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p, true)),
          :s => Dtry(InnerPort(■.s, true))
        ),
        rotational_friction,
        Position(3,5)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s, true))
        ),
        tc,
        Position(4,4)
      ),
    ),
  )
);

@test assemble(rotor) == Eq[
  Eq(FVar(■.coil, ■.b), Neg(Add((Neg(EVar(■, ■.q)), Mul((XVar(■, ■.bₛ), Div(XVar(■.mass, ■.p), Const(1.0)))), Mul((Const(0.01), Div(XVar(■.coil, ■.b), Const(1.0))))))))
  Eq(FVar(■.mass, ■.p), Add((Neg(Add((Neg(Mul((XVar(■, ■.bₛ), Div(XVar(■.coil, ■.b), Const(1.0))))), Mul((Const(0.01), Div(XVar(■.mass, ■.p), Const(1.0))))))), FVar(■, ■.p))))
  Eq(FVar(■.tc, ■.s), Neg(Add((Neg(Div(Mul((Const(0.01), Div(XVar(■.coil, ■.b), Const(1.0)), Div(XVar(■.coil, ■.b), Const(1.0)))), Mul((Div(Const(1.0), Const(2.5)), Exp(Div(XVar(■.tc, ■.s), Const(2.5))))))), Neg(Div(Mul((Const(0.01), Div(XVar(■.mass, ■.p), Const(1.0)), Div(XVar(■.mass, ■.p), Const(1.0)))), Mul((Div(Const(1.0), Const(2.5)), Exp(Div(XVar(■.tc, ■.s), Const(2.5)))))))))))
]


## motor

motor = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(true, charge, true, Position(2,1))),
    :bₛ => Dtry(Junction(false, magnetic_flux, false, Position(2,2))),
    :p => Dtry(Junction(true, angular_momentum, true, Position(3,3))),
  ),
  Dtry(
    :stator => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q, true)),
          :b => Dtry(InnerPort(■.bₛ, false)),
        ),
        stator,
        Position(1,2)
      ),
    ),
    :rotor => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q, true)),
          :bₛ => Dtry(InnerPort(■.bₛ, false)),
          :p => Dtry(InnerPort(■.p, true)),
        ),
        rotor,
        Position(3,2)
      ),
    ),
  )
);

@test assemble(motor) == Eq[
  Eq(FVar(■.stator.coil, ■.b), Neg(Add((Neg(EVar(■, ■.q)), Mul((Const(0.01), Div(XVar(■.stator.coil, ■.b), Const(1.0))))))))
  Eq(FVar(■.stator.tc, ■.s), Div(Mul((Const(0.01), Div(XVar(■.stator.coil, ■.b), Const(1.0)), Div(XVar(■.stator.coil, ■.b), Const(1.0)))), Mul((Div(Const(1.0), Const(2.5)), Exp(Div(XVar(■.stator.tc, ■.s), Const(2.5)))))))
  Eq(FVar(■.rotor.coil, ■.b), Neg(Add((Neg(EVar(■, ■.q)), Mul((XVar(■.stator.coil, ■.b), Div(XVar(■.rotor.mass, ■.p), Const(1.0)))), Mul((Const(0.01), Div(XVar(■.rotor.coil, ■.b), Const(1.0))))))))
  Eq(FVar(■.rotor.mass, ■.p), Add((Neg(Add((Neg(Mul((XVar(■.stator.coil, ■.b), Div(XVar(■.rotor.coil, ■.b), Const(1.0))))), Mul((Const(0.01), Div(XVar(■.rotor.mass, ■.p), Const(1.0))))))), FVar(■, ■.p))))
  Eq(FVar(■.rotor.tc, ■.s), Neg(Add((Neg(Div(Mul((Const(0.01), Div(XVar(■.rotor.coil, ■.b), Const(1.0)), Div(XVar(■.rotor.coil, ■.b), Const(1.0)))), Mul((Div(Const(1.0), Const(2.5)), Exp(Div(XVar(■.rotor.tc, ■.s), Const(2.5))))))), Neg(Div(Mul((Const(0.01), Div(XVar(■.rotor.mass, ■.p), Const(1.0)), Div(XVar(■.rotor.mass, ■.p), Const(1.0)))), Mul((Div(Const(1.0), Const(2.5)), Exp(Div(XVar(■.rotor.tc, ■.s), Const(2.5)))))))))))
]


## system with motor

# TODO add flywheel and extend assembly to DAE case
# TODO connect piston with crank mechanism?

load_res = IrreversibleComponent(
  Dtry(
    :p => Dtry(IrreversiblePort(angular_momentum, Const(0.5) * EVar(:p))),
    :s => Dtry(IrreversiblePort(entropy, -((Const(0.5) * EVar(:p) * EVar(:p)) / (θ₀ + EVar(:s)))))
  )
)

load = CompositeSystem(
  Dtry(
    :p => Dtry(Junction(true, angular_momentum, true, Position(1,1))),
    :s => Dtry(Junction(false, entropy, true, Position(1,3))),
  ),
  Dtry(
    :res => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p, true)),
          :s => Dtry(InnerPort(■.s, true)),
        ),
        load_res,
        Position(1,2)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s, true)),
        ),
        tc,
        Position(1,4)
      ),
    ),
  )
);


motor_rig = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(true, charge, true, Position(1,1))),
    :p => Dtry(Junction(false, angular_momentum, true, Position(1,3))),
  ),
  Dtry(
    :motor => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q, true)),
          :p => Dtry(InnerPort(■.p, true)),
        ),
        motor,
        Position(1,2)
      ),
    ),
    :load => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p, true)),
        ),
        load,
        Position(1,4)
      ),
    ),
  )
);

@test assemble(motor_rig) == Eq[
  Eq(FVar(■.motor.stator.coil, ■.b), Neg(Add((Neg(EVar(■, ■.q)), Mul((Const(0.01), Div(XVar(■.motor.stator.coil, ■.b), Const(1.0))))))))
  Eq(FVar(■.motor.stator.tc, ■.s), Div(Mul((Const(0.01), Div(XVar(■.motor.stator.coil, ■.b), Const(1.0)), Div(XVar(■.motor.stator.coil, ■.b), Const(1.0)))), Mul((Div(Const(1.0), Const(2.5)), Exp(Div(XVar(■.motor.stator.tc, ■.s), Const(2.5)))))))
  Eq(FVar(■.motor.rotor.coil, ■.b), Neg(Add((Neg(EVar(■, ■.q)), Mul((XVar(■.motor.stator.coil, ■.b), Div(XVar(■.motor.rotor.mass, ■.p), Const(1.0)))), Mul((Const(0.01), Div(XVar(■.motor.rotor.coil, ■.b), Const(1.0))))))))
  Eq(FVar(■.motor.rotor.mass, ■.p), Neg(Add((Neg(Mul((XVar(■.motor.stator.coil, ■.b), Div(XVar(■.motor.rotor.coil, ■.b), Const(1.0))))), Mul((Const(0.01), Div(XVar(■.motor.rotor.mass, ■.p), Const(1.0)))), Mul((Const(0.5), Div(XVar(■.motor.rotor.mass, ■.p), Const(1.0))))))))
  Eq(FVar(■.motor.rotor.tc, ■.s), Neg(Add((Neg(Div(Mul((Const(0.01), Div(XVar(■.motor.rotor.coil, ■.b), Const(1.0)), Div(XVar(■.motor.rotor.coil, ■.b), Const(1.0)))), Mul((Div(Const(1.0), Const(2.5)), Exp(Div(XVar(■.motor.rotor.tc, ■.s), Const(2.5))))))), Neg(Div(Mul((Const(0.01), Div(XVar(■.motor.rotor.mass, ■.p), Const(1.0)), Div(XVar(■.motor.rotor.mass, ■.p), Const(1.0)))), Mul((Div(Const(1.0), Const(2.5)), Exp(Div(XVar(■.motor.rotor.tc, ■.s), Const(2.5)))))))))))
  Eq(FVar(■.load.tc, ■.s), Div(Mul((Const(0.5), Div(XVar(■.motor.rotor.mass, ■.p), Const(1.0)), Div(XVar(■.motor.rotor.mass, ■.p), Const(1.0)))), Mul((Div(Const(1.0), Const(2.5)), Exp(Div(XVar(■.load.tc, ■.s), Const(2.5)))))))
]

# 377.000 μs (5460 allocations: 199.62 KiB) arbitrary nesting of patterns
# 318.042 μs (4633 allocations: 172.94 KiB) check=false
# 236.334 μs (3609 allocations: 129.45 KiB) isflat
# 216.250 μs (3320 allocations: 119.23 KiB) refactor Position, convenience constructors
# 249.166 μs (3885 allocations: 135.36 KiB) components as values, dtry
# @btime assemble($motor_rig);

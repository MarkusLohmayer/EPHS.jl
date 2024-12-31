# DC shunt motor

## stator

emc = EMC();
coil = Coil(Const(1.));
res = LinearResistance(Const(0.01));
tc = ThermalCapacity(Const(1.), Const(2.5));

stator = CompositeSystem(
  Dtry{Tuple{Junction,Position}}(
    :q => Dtry{Tuple{Junction,Position}}((
      Junction(true, charge, true),
      Position(2,1)
    )),
    :b => Dtry{Tuple{Junction,Position}}((
      Junction(true, magnetic_flux, false),
      Position(2,3)
    )),
    :s => Dtry{Tuple{Junction,Position}}((
      Junction(false, entropy, true),
      Position(2,5)
    )),
  ),
  Dtry{Tuple{InnerBox{AbstractSystem},Position}}(
    :emc => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :q => Dtry{InnerPort}(InnerPort(■.q, true)),
          :b => Dtry{InnerPort}(InnerPort(■.b, true)),
        ),
        emc
      ),
      Position(2,2)
    )),
    :coil => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :b => Dtry{InnerPort}(InnerPort(■.b, true)),
        ),
        coil
      ),
      Position(1,3)
    )),
    :res => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :b => Dtry{InnerPort}(InnerPort(■.b, true)),
          :s => Dtry{InnerPort}(InnerPort(■.s, true))
        ),
        res
      ),
      Position(2,4)
    )),
    :tc => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :s => Dtry{InnerPort}(InnerPort(■.s, true))
        ),
        tc
      ),
      Position(1,5)
    )),
  )
);

@test assemble(stator) == Eq[
  Eq(FVar(■.coil, ■.b), Neg(Add((Neg(EVar(■, ■.q)), Mul((Const(0.01), Div(XVar(■.coil, ■.b), Const(1.0))))))))
  Eq(FVar(■.tc, ■.s), Div(Mul((Const(0.01), Div(XVar(■.coil, ■.b), Const(1.0)), Div(XVar(■.coil, ■.b), Const(1.0)))), Mul((Div(Const(1.0), Const(2.5)), Exp(Div(XVar(■.tc, ■.s), Const(2.5)))))))
]


## rotor

mkc = MKC();
angular_mass = AngularMass(Const(1.));
rotational_friction = LinearRotationalFriction(Const(0.01));

rotor = CompositeSystem(
  Dtry{Tuple{Junction,Position}}(
    :q => Dtry{Tuple{Junction,Position}}((
      Junction(true, charge, true),
      Position(1,2)
    )),
    :b => Dtry{Tuple{Junction,Position}}((
      Junction(false, magnetic_flux, false),
      Position(2,3)
    )),
    :bₛ => Dtry{Tuple{Junction,Position}}((
      Junction(true, magnetic_flux, false),
      Position(1,4)
    )),
    :p => Dtry{Tuple{Junction,Position}}((
      Junction(true, angular_momentum, true),
      Position(2,5)
    )),
    :s => Dtry{Tuple{Junction,Position}}((
      Junction(false, entropy, true),
      Position(3,4)
    )),
  ),
  Dtry{Tuple{InnerBox{AbstractSystem},Position}}(
    :emc => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :q => Dtry{InnerPort}(InnerPort(■.q, true)),
          :b => Dtry{InnerPort}(InnerPort(■.b, true)),
        ),
        emc
      ),
      Position(2,2)
    )),
    :coil => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :b => Dtry{InnerPort}(InnerPort(■.b, true)),
        ),
        coil
      ),
      Position(1,3)
    )),
    :mkc => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :b => Dtry{InnerPort}(InnerPort(■.b, true)),
          :p => Dtry{InnerPort}(InnerPort(■.p, true)),
          :bₛ => Dtry{InnerPort}(InnerPort(■.bₛ, false)),
        ),
        mkc
      ),
      Position(2,4)
    )),
    :mass => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :p => Dtry{InnerPort}(InnerPort(■.p, true)),
        ),
        angular_mass
      ),
      Position(1,5)
    )),
    :res => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :b => Dtry{InnerPort}(InnerPort(■.b, true)),
          :s => Dtry{InnerPort}(InnerPort(■.s, true))
        ),
        res
      ),
      Position(3,3)
    )),
    :mf => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :p => Dtry{InnerPort}(InnerPort(■.p, true)),
          :s => Dtry{InnerPort}(InnerPort(■.s, true))
        ),
        rotational_friction
      ),
      Position(3,5)
    )),
    :tc => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :s => Dtry{InnerPort}(InnerPort(■.s, true))
        ),
        tc
      ),
      Position(4,4)
    )),
  )
);

@test assemble(rotor) == Eq[
  Eq(FVar(■.coil, ■.b), Neg(Add((Neg(EVar(■, ■.q)), Mul((XVar(■, ■.bₛ), Div(XVar(■.mass, ■.p), Const(1.0)))), Mul((Const(0.01), Div(XVar(■.coil, ■.b), Const(1.0))))))))
  Eq(FVar(■.mass, ■.p), Add((Neg(Add((Neg(Mul((XVar(■, ■.bₛ), Div(XVar(■.coil, ■.b), Const(1.0))))), Mul((Const(0.01), Div(XVar(■.mass, ■.p), Const(1.0))))))), FVar(■, ■.p))))
  Eq(FVar(■.tc, ■.s), Neg(Add((Neg(Div(Mul((Const(0.01), Div(XVar(■.coil, ■.b), Const(1.0)), Div(XVar(■.coil, ■.b), Const(1.0)))), Mul((Div(Const(1.0), Const(2.5)), Exp(Div(XVar(■.tc, ■.s), Const(2.5))))))), Neg(Div(Mul((Const(0.01), Div(XVar(■.mass, ■.p), Const(1.0)), Div(XVar(■.mass, ■.p), Const(1.0)))), Mul((Div(Const(1.0), Const(2.5)), Exp(Div(XVar(■.tc, ■.s), Const(2.5)))))))))))
]


## motor

motor = CompositeSystem(
  Dtry{Tuple{Junction,Position}}(
    :q => Dtry{Tuple{Junction,Position}}((
      Junction(true, charge, true),
      Position(2,1)
    )),
    :bₛ => Dtry{Tuple{Junction,Position}}((
      Junction(false, magnetic_flux, false),
      Position(2,2)
    )),
    :p => Dtry{Tuple{Junction,Position}}((
      Junction(true, angular_momentum, true),
      Position(3,3)
    )),
  ),
  Dtry{Tuple{InnerBox{AbstractSystem},Position}}(
    :stator => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :q => Dtry{InnerPort}(InnerPort(■.q, true)),
          :b => Dtry{InnerPort}(InnerPort(■.bₛ, false)),
        ),
        stator
      ),
      Position(1,2)
    )),
    :rotor => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :q => Dtry{InnerPort}(InnerPort(■.q, true)),
          :bₛ => Dtry{InnerPort}(InnerPort(■.bₛ, false)),
          :p => Dtry{InnerPort}(InnerPort(■.p, true)),
        ),
        rotor
      ),
      Position(3,2)
    )),
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

load = CompositeSystem(
  Dtry{Tuple{Junction,Position}}(
    :p => Dtry{Tuple{Junction,Position}}((
      Junction(true, angular_momentum, true),
      Position(1,1)
    )),
    :s => Dtry{Tuple{Junction,Position}}((
      Junction(false, entropy, true),
      Position(1,3)
    )),
  ),
  Dtry{Tuple{InnerBox{AbstractSystem},Position}}(
    :res => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :p => Dtry{InnerPort}(InnerPort(■.p, true)),
          :s => Dtry{InnerPort}(InnerPort(■.s, true)),
        ),
        LinearRotationalFriction(Const(0.5))
      ),
      Position(1,2)
    )),
    :tc => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :s => Dtry{InnerPort}(InnerPort(■.s, true)),
        ),
        tc
      ),
      Position(1,4)
    )),
  )
);


motor_rig = CompositeSystem(
  Dtry{Tuple{Junction,Position}}(
    :q => Dtry{Tuple{Junction,Position}}((
      Junction(true, charge, true),
      Position(1,1)
    )),
    :p => Dtry{Tuple{Junction,Position}}((
      Junction(false, angular_momentum, true),
      Position(1,3)
    )),
  ),
  Dtry{Tuple{InnerBox{AbstractSystem},Position}}(
    :motor => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :q => Dtry{InnerPort}(InnerPort(■.q, true)),
          :p => Dtry{InnerPort}(InnerPort(■.p, true)),
        ),
        motor
      ),
      Position(1,2)
    )),
    :load => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :p => Dtry{InnerPort}(InnerPort(■.p, true)),
        ),
        load
      ),
      Position(1,4)
    )),
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
# @btime assemble($motor_rig)

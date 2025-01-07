# mechanical oscillator with constraint (two masses)

cm = ReversibleComponent(
  Dtry(
    :p => Dtry(ReversiblePort(FlowPort(momentum, CVar(:λ)))),
    :p₂ => Dtry(ReversiblePort(FlowPort(momentum, -CVar(:λ)))),
    :λ => Dtry(ReversiblePort(Constraint(-EVar(:p) + EVar(:p₂))))
  )
);

osc_constraint_masses = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(displacement, Position(1, 2))),
    :p => Dtry(Junction(momentum, Position(1, 4))),
    :p₂ => Dtry(Junction(momentum, Position(3, 4))),
  ),
  Dtry(
    :pe => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
        ),
        pe,
        Position(1, 1)
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
    :ke => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        ke,
        Position(1, 5)
      ),
    ),
    :ke₂ => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p₂)),
        ),
        ke,
        Position(3, 5)
      ),
    ),
    :cm => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :p₂ => Dtry(InnerPort(■.p₂)),
        ),
        cm,
        Position(2, 4)
      ),
    ),
  )
);

ps = Dtry(
  :ke => Dtry(
    :m => Dtry(0.75)
  ),
  :ke₂ => Dtry(
    :m => Dtry(0.25)
  ),
);

ic = Dtry(
  :pe => Dtry(
    :q => Dtry(1.0),
  ),
  :ke => Dtry(
    :p => Dtry(0.0),
  ),
  :ke₂ => Dtry(
    :p => Dtry(0.0),
  ),
);

sim_masses = simulate(osc_constraint_masses, midpoint_rule, ic, h, t; ps);

q = XVar(DtryPath(:pe), DtryPath(:q))
p = XVar(DtryPath(:ke), DtryPath(:p))
p₂ = XVar(DtryPath(:ke₂), DtryPath(:p))
@test evolution(sim_osc, q) ≈ evolution(sim_masses, q)
@test evolution(sim_osc, p) ≈ evolution(sim_masses, p + p₂)

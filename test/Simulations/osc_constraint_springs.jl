# constrained mechanical oscillator with non-linear spring
# Thesis: Chapter 13

# using Test, EPHS, Plots

pe₁ = let
  k = Par(:k, 1.5)
  q = XVar(:q)
  E = Const(1 / 2) * k * q^Const(2) + Const(1 / 4) * k * q^Const(4)
  StorageComponent(
    Dtry(
      :q => Dtry(displacement)
    ),
    E
  )
end

pe₂ = let
  k = Par(:k, 2.0)
  q = XVar(:q)
  E = Const(1 / 2) * k * q^Const(2)
  StorageComponent(
    Dtry(
      :q => Dtry(displacement)
    ),
    E
  )
end

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
end

sc = let
  λ = CVar(:λ)
  ReversibleComponent(
    Dtry(
      :q => Dtry(ReversiblePort(FlowPort(displacement, λ))),
      :q₂ => Dtry(ReversiblePort(FlowPort(displacement, -λ))),
      :λ => Dtry(ReversiblePort(Constraint(-EVar(:q) + EVar(:q₂))))
    )
  )
end

pkc = ReversibleComponent(
  Dtry(
    :q => Dtry(ReversiblePort(FlowPort(displacement, -EVar(:p)))),
    :p => Dtry(ReversiblePort(FlowPort(momentum, EVar(:q))))
  )
)

osc_constraint = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(displacement, Position(1, 2))),
    :p => Dtry(Junction(momentum, Position(1, 4))),
    :q₂ => Dtry(Junction(displacement, Position(3, 2))),
  ),
  Dtry(
    :pe₁ => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
        ),
        pe₁,
        Position(1, 1)
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
    :sc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
          :q₂ => Dtry(InnerPort(■.q₂)),
        ),
        sc,
        Position(2, 2)
      ),
    ),
    :pe₂ => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q₂)),
        ),
        pe₂,
        Position(3, 1)
      ),
    ),
  )
)

h = 0.01
t = 10.0

ic = Dtry(
  :ke => Dtry(
    :p => Dtry(9.0),
  ),
  # initial condition for pe₁.q missing
  :pe₂ => Dtry(
    :q => Dtry(0.0),
  )
);
@test_throws ErrorException simulate(osc_constraint, midpoint_rule, ic, h, t);

ic = Dtry(
  :ke => Dtry(
    :p => Dtry(0.0),
  ),
  :pe₁ => Dtry(
    :q => Dtry(1.0), # not consistent
  ),
  :pe₂ => Dtry(
    :q => Dtry(0.0),
  )
);
@test_throws ErrorException simulate(osc_constraint, midpoint_rule, ic, h, t);

ic = Dtry(
  :ke => Dtry(
    :p => Dtry(9.0),
  ),
  :pe₁ => Dtry(
    :q => Dtry(0.0),
  ),
  :pe₂ => Dtry(
    :q => Dtry(0.0),
  )
);
sim_constraint = simulate(osc_constraint, midpoint_rule, ic, h, t);

# midpoint_rule(assemble(osc_constraint))

dae = assemble(osc_constraint)
pe₁₊q₊e = dae.storage[2].effort
pe₂₊q₊e = dae.storage[3].effort

function constraint_err(sim)
  force1 = evolution(sim, pe₁₊q₊e)
  force2 = evolution(sim, pe₂₊q₊e)
  residual = force1 - force2
  maximum(abs.(residual)) / maximum(abs.(force1))
end

constraint_err(sim_constraint)

energy = total_energy(osc_constraint)

function energy_err(sim)
  energie = evolution(sim, energy)
  residual = energie .- energie[1]
  maximum(abs.(residual)) / abs(energie[1])
end

energy_err(sim_constraint)


# using Plots

# plot_evolution(sim_constraint,
#   XVar(DtryPath(:pe₁), DtryPath(:q)),
#   XVar(DtryPath(:pe₂), DtryPath(:q));
#   ylabel="displacement [m]"
# )

# savefig("osc_constraint_q.pdf")

# plot_evolution(sim_constraint,
#   "total energy" => total_energy(osc_constraint),
#   "ke" => total_energy(ke; box_path=DtryPath(:ke)),
#   "pe₁" => total_energy(pe₁; box_path=DtryPath(:pe₁)),
#   "pe₂" => total_energy(pe₂; box_path=DtryPath(:pe₂));
#   ylims=(0, Inf),
#   ylabel="energy [J]",
#   legend=:right,
# )

# savefig("osc_constraint_energy.pdf")

# hs = [0.1, 0.05, 0.02, 0.01, 0.005, 0.002, 0.001]

# plot_convergence(
#   osc_constraint,
#   ic,
#   hs,
#   t,
#   energy_err,
#   midpoint_rule,
#   [2];
#   ylabel="relative error [1]"
# )

# savefig("osc_constraint_convergence_energy.pdf")

# plot_convergence(
#   osc_constraint,
#   ic,
#   hs,
#   t,
#   constraint_err,
#   midpoint_rule,
#   [2];
#   ylabel="relative error [1]"
# )

# savefig("osc_constraint_convergence_constraint.pdf")

module TestSimOsc

using Test, EPHS, StaticArrays

## Mechanical oscillator

pe = hookean_spring(1.5);
ke = point_mass(1.0);

osc = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(displacement, Position(1, 2))),
    :p => Dtry(Junction(momentum, Position(1, 4))),
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
  )
);


function update_hand(x₀, h)
  p₀, q₀ = x₀
  function residual(x₁)
    p₁, q₁ = x₁
    p = (p₀ + p₁) / 2
    q = (q₀ + q₁) / 2
    SA[
      (p₁-p₀)-h*(-1.5q),
      (q₁-q₀)-h*(p/1.0),
    ]
  end
  x₁ = nlsolve(residual, x₀)
end


dae = assemble(osc);
update_prog = midpoint_rule(dae)
x₀ = SA[0.0, 1.0] # [p₀, q₀]
h = 0.01
t = 10.0
xs_hand = simulate(update_hand, x₀, h, t)
xs_prog = simulate(update_prog, x₀, h, t)
@test xs_hand == xs_prog


# Higher-level interface
# Initial conditions as directory
ic = Dtry(
  :pe => Dtry(
    :q => Dtry(1.0),
  ),
  :ke => Dtry(
    :p => Dtry(0.0),
  ),
);
sim_osc = simulate(osc, midpoint_rule, ic, h, t);
@test xs_prog == sim_osc.xs


# using Plots
# q = XVar(DtryPath(:pe), DtryPath(:q))
# p = XVar(DtryPath(:ke), DtryPath(:p))
# plot_evolution(sim_osc, q, p)


## Constrained oscillator with two rigidly-connected masses

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
        two_masses_rigid_connection,
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


## Damped oscillator

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
          hookean_spring(1.5),
          Position(1, 1)
        ),
      ),
      :ke => Dtry(
        InnerBox(
          Dtry(
            :p => Dtry(InnerPort(■.p)),
          ),
          point_mass(1.0),
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
        linear_friction(0.02),
        Position(2, 4)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        thermal_capacity(1.0, 2.0),
        Position(2, 6)
      ),
    ),
  )
);

ic = Dtry(
  :osc => Dtry(
    :pe => Dtry(
      :q => Dtry(1.0),
    ),
    :ke => Dtry(
      :p => Dtry(0.0),
    ),
  ),
  :tc => Dtry(
    :s => Dtry(16.56)
  ),
);

sim = simulate(osc_damped_flat, midpoint_rule, ic, 0.01, 20);


# q = XVar(DtryPath(:osc, :pe), DtryPath(:q))
# p = XVar(DtryPath(:osc, :ke), DtryPath(:p))
# s = XVar(DtryPath(:tc), DtryPath(:s))
# plot_evolution(sim, q)
# plot_evolution(sim, s)

end

"""
Isolated cylinder-piston device
Thesis: Section 3.3
"""
module TestCPD

using Test, EPHS


piston = CompositeSystem(
  Dtry(
    :v₁ => Dtry(Junction(volume, Position(1, 0), exposed=true)),
    :v₂ => Dtry(Junction(volume, Position(1, 4), exposed=true)),
    :s₁ => Dtry(Junction(entropy, Position(4, 0), exposed=true)),
    :s₂ => Dtry(Junction(entropy, Position(4, 4), exposed=true)),
    :s => Dtry(Junction(entropy, Position(4, 2))),
    :p => Dtry(Junction(momentum, Position(2, 2))),
  ),
  Dtry(
    :ke => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        point_mass(0.5),
        Position(2, 1)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        thermal_capacity(1.0, 2.0),
        Position(5, 2)
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :s => Dtry(InnerPort(■.s)),
        ),
        linear_friction(0.02),
        Position(3, 2)
      ),
    ),
    :ht₁ => Dtry(
      InnerBox(
        Dtry(
          :s₁ => Dtry(InnerPort(■.s₁)),
          :s₂ => Dtry(InnerPort(■.s)),
        ),
        heat_transfer(1e-3),
        Position(4, 1)
      ),
    ),
    :ht₂ => Dtry(
      InnerBox(
        Dtry(
          :s₁ => Dtry(InnerPort(■.s₂)),
          :s₂ => Dtry(InnerPort(■.s)),
        ),
        heat_transfer(1e-3),
        Position(4, 3)
      ),
    ),
    :hkc => Dtry(
      InnerBox(
        Dtry(
          :v₁ => Dtry(InnerPort(■.v₁)),
          :v₂ => Dtry(InnerPort(■.v₂)),
          :p => Dtry(InnerPort(■.p)),
        ),
        hkc(1.963e-2),
        Position(1, 2)
      ),
    ),
  ),
)

gas₁ = ideal_gas(1.0, 2.5, 1.0, 1.5);
gas₂ = gas₁;

cpd = CompositeSystem(
  Dtry(
    :v₁ => Dtry(Junction(volume, Position(1, 2))),
    :v₂ => Dtry(Junction(volume, Position(1, 4))),
    :s₁ => Dtry(Junction(entropy, Position(3, 2))),
    :s₂ => Dtry(Junction(entropy, Position(3, 4))),
  ),
  Dtry(
    :gas₁ => Dtry(
      InnerBox(
        Dtry(
          :v => Dtry(InnerPort(■.v₁)),
          :s => Dtry(InnerPort(■.s₁))
        ),
        gas₁,
        Position(2, 1)
      ),
    ),
    :gas₂ => Dtry(
      InnerBox(
        Dtry(
          :v => Dtry(InnerPort(■.v₂)),
          :s => Dtry(InnerPort(■.s₂)),
        ),
        gas₂,
        Position(2, 5)
      ),
    ),
    :piston => Dtry(
      InnerBox(
        Dtry(
          :v₁ => Dtry(InnerPort(■.v₁)),
          :v₂ => Dtry(InnerPort(■.v₂)),
          :s₁ => Dtry(InnerPort(■.s₁)),
          :s₂ => Dtry(InnerPort(■.s₂)),
        ),
        piston,
        Position(2, 3)
      ),
    ),
  ),
)

ic = Dtry(
  :gas₁ => Dtry(
    :s => Dtry(1.0),
    :v => Dtry(0.1),
  ),
  :gas₂ => Dtry(
    :s => Dtry(1.0),
    :v => Dtry(0.9),
  ),
  :piston => Dtry(
    :ke => Dtry(
      :p => Dtry(0.0)
    ),
    :tc => Dtry(
      :s => Dtry(1.0),
    ),
  ),
)

sim = simulate(cpd, midpoint_rule, ic, 0.1, 200.0);

gas₁₊s = XVar(DtryPath(:gas₁), DtryPath(:s));
gas₁₊v = XVar(DtryPath(:gas₁), DtryPath(:v));
gas₂₊s = XVar(DtryPath(:gas₂), DtryPath(:s));
gas₂₊v = XVar(DtryPath(:gas₂), DtryPath(:v));
p = XVar(DtryPath(:piston, :ke), DtryPath(:p));
tc₊s = XVar(DtryPath(:piston, :tc), DtryPath(:s));

# check invariant: total energy
es = evolution(sim, total_energy(cpd));
@test all(abs(e) ≤ 1e-3 for e in es .- es[1])

# check invariant: total volume
vs = evolution(sim, gas₁₊v + gas₂₊v);
@test all(abs(v) ≤ 1e-15 for v in vs .- vs[1])


# using Plots

# plot_evolution(sim,
#   gas₁₊v,
#   gas₂₊v,
#   "total volume" => gas₁₊v + gas₂₊v;
#   ylims=(0, Inf),
#   ylabel="volume [m³]",
# )

# savefig("cpd_volume.pdf")

# plot_evolution(sim,
#   gas₁₊s,
#   gas₂₊s,
#   tc₊s,
#   "total entropy" => total_entropy(cpd);
#   ylims=(0, Inf),
#   ylabel="entropy [J/K]",
#   legend=:topright
# )

# savefig("cpd_entropy.pdf")

# plot_evolution(sim, p)

# plot_evolution(sim,
#   "total energy" => total_energy(cpd),
#   "gas₁" => total_energy(gas₁; box_path=DtryPath(:gas₁)),
#   "gas₂" => total_energy(gas₂; box_path=DtryPath(:gas₂)),
#   "piston" => total_energy(piston; box_path=DtryPath(:piston));
#   ylims=(0, Inf),
#   ylabel="energy [J]",
#   legend=:topright
# )

# savefig("cpd_energy.pdf")

end

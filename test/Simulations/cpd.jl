# isolated cylinder-piston device
# Thesis: Chapter 14

# using Test, EPHS, Plots

gas = let
  c₁ = Par(:c₁, 1.0)
  c₂ = Par(:c₂, 2.5)
  v₀ = Par(:v₀, 1.0)
  c = Par(:c, 3 / 2)
  s = XVar(:s)
  v = XVar(:v)
  E = c₁ * exp(s / c₂) * (v₀ / v)^(Const(1) / c)
  StorageComponent(
    Dtry(
      :s => Dtry(entropy),
      :v => Dtry(volume),
    ),
    E
  )
end

ke = let
  m = Par(:m, 5e-1)
  p = XVar(:p)
  E = Const(1 / 2) * p^Const(2) / m
  StorageComponent(
    Dtry(
      :p => Dtry(momentum)
    ),
    E
  )
end

tc = let
  c₁ = Par(:c₁, 1.0)
  c₂ = Par(:c₂, 2.0)
  s = XVar(:s)
  E = c₁ * exp(s / c₂)
  StorageComponent(
    Dtry(
      :s => Dtry(entropy)
    ),
    E
  )
end

hkc = let
  a = Par(:a, 1.963e-2)
  v₁₊e = EVar(:v₁)
  v₂₊e = EVar(:v₂)
  p₊e = EVar(:p)
  v₁₊f = -(a * p₊e)
  v₂₊f = a * p₊e
  p₊f = a * (v₁₊e - v₂₊e)
  ReversibleComponent(
    Dtry(
      :v₁ => Dtry(ReversiblePort(FlowPort(volume, v₁₊f))),
      :v₂ => Dtry(ReversiblePort(FlowPort(volume, v₂₊f))),
      :p => Dtry(ReversiblePort(FlowPort(momentum, p₊f))),
    ))
end;

ht = let
  α = Par(:α, 1e-3)
  s₁₊e = EVar(:s₁)
  s₂₊e = EVar(:s₂)
  θ₁ = θ₀ + s₁₊e
  θ₂ = θ₀ + s₂₊e
  s₁₊f = -(α * (θ₂ - θ₁) / θ₁)
  s₂₊f = -(α * (θ₁ - θ₂) / θ₂)
  IrreversibleComponent(
    Dtry(
      :s₁ => Dtry(IrreversiblePort(entropy, s₁₊f)),
      :s₂ => Dtry(IrreversiblePort(entropy, s₂₊f)),
    )
  )
end

mf = let
  d = Par(:d, 0.02)
  p₊e = EVar(:p)
  s₊e = EVar(:s)
  p₊f = d * p₊e
  s₊f = -((d * p₊e * p₊e) / (θ₀ + s₊e))
  IrreversibleComponent(
    Dtry(
      :p => Dtry(IrreversiblePort(momentum, p₊f)),
      :s => Dtry(IrreversiblePort(entropy, s₊f)),
    )
  )
end

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
        ke,
        Position(2, 1)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        tc,
        Position(5, 2)
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :s => Dtry(InnerPort(■.s)),
        ),
        mf,
        Position(3, 2)
      ),
    ),
    :ht₁ => Dtry(
      InnerBox(
        Dtry(
          :s₁ => Dtry(InnerPort(■.s₁)),
          :s₂ => Dtry(InnerPort(■.s)),
        ),
        ht,
        Position(4, 1)
      ),
    ),
    :ht₂ => Dtry(
      InnerBox(
        Dtry(
          :s₁ => Dtry(InnerPort(■.s₂)),
          :s₂ => Dtry(InnerPort(■.s)),
        ),
        ht,
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
        hkc,
        Position(1, 2)
      ),
    ),
  ),
)

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
        gas,
        Position(2, 1)
      ),
    ),
    :gas₂ => Dtry(
      InnerBox(
        Dtry(
          :v => Dtry(InnerPort(■.v₂)),
          :s => Dtry(InnerPort(■.s₂)),
        ),
        gas,
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

sim = simulate(cpd, midpoint_rule, ic, 0.1, 200.);

gas₁₊s = XVar(DtryPath(:gas₁), DtryPath(:s))
gas₁₊v = XVar(DtryPath(:gas₁), DtryPath(:v))
gas₂₊s = XVar(DtryPath(:gas₂), DtryPath(:s))
gas₂₊v = XVar(DtryPath(:gas₂), DtryPath(:v))
p = XVar(DtryPath(:piston, :ke), DtryPath(:p))
tc₊s = XVar(DtryPath(:piston, :tc), DtryPath(:s))

# check invariant: total energy
es = evolution(sim, total_energy(cpd));
@test all(abs(e) ≤ 1e-3 for e in es .- es[1])

# check invariant: total volume
vs = evolution(sim, gas₁₊v + gas₂₊v);
@test all(abs(v) ≤ 1e-15 for v in vs .- vs[1])


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
#   "gas₁" => total_energy(gas; box_path=DtryPath(:gas₁)),
#   "gas₂" => total_energy(gas; box_path=DtryPath(:gas₂)),
#   "piston" => total_energy(piston; box_path=DtryPath(:piston));
#   ylims=(0, Inf),
#   ylabel="energy [J]",
#   legend=:topright
# )

# savefig("cpd_energy.pdf")

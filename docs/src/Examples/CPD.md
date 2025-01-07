# Cylinder-piston device

````@setup 1
using EPHS, Plots
````

In this example, we consider
an isolated cylinder
and a piston that divides the cylinder
into two gas-filled compartments:

```@raw html
<div style="text-align: center;">
    <img src="../../assets/examples/cpd.svg" width="400"/>
</div>
&nbsp;
```

Due to mechanical friction during its movement,
the piston heats up.
Temperature differences
between the piston
and the gas in each compartment
result in heat transfer.


## Storage components

We start by defining
three [storage components](@ref StorageComponent)
that model
the kinetic energy of the piston,
the internal energy of the piston, and
the internal energy of the gas in each compartment:

```@example 1
mass = let
  I = Dtry(                           # interface
    :p => Dtry(momentum)              # port for exchange of momentum and kinetic energy
  )
  p = XVar(:p)                        # state variable
  m = Par(:m, 0.5)                    # mass of the piston
  E = Const(1 / 2) * p^Const(2) / m   # energy function
  StorageComponent(I, E)
end

tc = let
  I = Dtry(
    :s => Dtry(entropy)
  )
  s = XVar(:s)
  c₁ = Par(:c₁, 1.0)
  c₂ = Par(:c₂, 2.0)
  E = c₁ * exp(s / c₂)
  StorageComponent(I, E)
end

gas = let
  I  = Dtry(
    :s => Dtry(entropy),
    :v => Dtry(volume),
  )
  s = XVar(:s)
  v = XVar(:v)
  c₁ = Par(:c₁, 1.0)
  c₂ = Par(:c₂, 2.5)
  v₀ = Par(:v₀, 1.0)
  c = Par(:c, 3 / 2)
  E = c₁ * exp(s / c₂) * (v₀ / v)^(Const(1) / c)
  StorageComponent(I, E)
end;
nothing # hide
```

## Reversible component

Next, we define
a [reversible component](@ref ReversibleComponent)
that models the coupling between
the two hydraulic energy domains
of the gas on either side of the piston
and the kinetic energy domain of the piston itself:

```@example 1
hkc = let
  a = Par(:a, 2e-2) # cross-sectional area of cylinder/piston
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
end
nothing # hide
```

The above defines
a skew-symmetric relation:

```math
\begin{bmatrix}
  \mathtt{p.f} \\
  \mathtt{v_1.f} \\
  \mathtt{v_2.f}
\end{bmatrix}
\: = \:
\begin{bmatrix}
   0 & a & -a \\
  -a & 0 &  0 \\
   a & 0 &  0 \\
\end{bmatrix}
\,
\begin{bmatrix}
  \mathtt{p.e} \\
  \mathtt{v_1.e} \\
  \mathtt{v_2.e}
\end{bmatrix}
```


## Irreversible components

Finally, we define
two [irreversible components](@ref IrreversibleComponent)
that model
mechanical friction and heat transfer:

```@example 1
mf = let
  d = Par(:d, 0.02) # friction coefficient
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

ht = let
  α = Par(:α, 1e-3) # heat transfer coefficient
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
end;
nothing # hide
```

Irreversible components are defined by
a symmetric, non-negative definite relation:

```math
\begin{bmatrix}
  \mathtt{p.f} \\
  \mathtt{s.f}
\end{bmatrix}
\: = \:
\frac{1}{\theta_{0}} \, d \,
\begin{bmatrix}
  \theta & \upsilon  \\
  - \upsilon & \frac{\upsilon^2}{\theta}
\end{bmatrix}
\,
\begin{bmatrix}
  \mathtt{p.e} \\
  \mathtt{s.e}
\end{bmatrix}
```

Here,
``\upsilon = \mathtt{p.e}``
is the velocity and
``\theta = \theta_{0} + \mathtt{s.e}``
is the absolute temperature
at which kinetic energy is dissipated
into the thermal energy domain.


```math
\begin{bmatrix}
  \mathtt{s₁.f} \\
  \mathtt{s₂.f}
\end{bmatrix}
\: = \:
\frac{1}{\theta_{0}}
\, \alpha \,
\begin{bmatrix}
  \frac{\theta_{2}}{\theta_{1}} & -1 \\
  -1 & \frac{\theta_{1}}{\theta_{2}}
\end{bmatrix}
\,
\begin{bmatrix}
  \mathtt{s₁.e} \\
  \mathtt{s₂.e}
\end{bmatrix}
```

Here,
``\theta_{1} = \theta_{0} + \mathtt{s₁.e}``
and
``\theta_{2} = \theta_{0} + \mathtt{s₂.e}``
represent the absolute temperature
of the two thermal energy domains.


## Composite system

To encapsulate the piston
into a reusable unit,
we model it as a separate [composite system](@ref CompositeSystem):

```@example 1
piston = CompositeSystem(
  Dtry(
    :v₁ => Dtry(Junction(volume, Position(1, 1), exposed=true)),
    :v₂ => Dtry(Junction(volume, Position(1, 5), exposed=true)),
    :s₁ => Dtry(Junction(entropy, Position(4, 1), exposed=true)),
    :s₂ => Dtry(Junction(entropy, Position(4, 5), exposed=true)),
    :s => Dtry(Junction(entropy, Position(4, 3))),
    :p => Dtry(Junction(momentum, Position(2, 3))),
  ),
  Dtry(
    :hkc => Dtry(
      InnerBox(
        Dtry(
          :v₁ => Dtry(InnerPort(■.v₁)),
          :v₂ => Dtry(InnerPort(■.v₂)),
          :p => Dtry(InnerPort(■.p)),
        ),
        hkc,
        Position(1, 3)
      ),
    ),
    :mass => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        mass,
        Position(2, 2)
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :s => Dtry(InnerPort(■.s)),
        ),
        mf,
        Position(3, 3)
      ),
    ),
    :ht₁ => Dtry(
      InnerBox(
        Dtry(
          :s₁ => Dtry(InnerPort(■.s₁)),
          :s₂ => Dtry(InnerPort(■.s)),
        ),
        ht,
        Position(4, 2)
      ),
    ),
    :ht₂ => Dtry(
      InnerBox(
        Dtry(
          :s₁ => Dtry(InnerPort(■.s₂)),
          :s₂ => Dtry(InnerPort(■.s)),
        ),
        ht,
        Position(4, 4)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        tc,
        Position(5, 3)
      ),
    ),
  ),
)
```

We then define
the model of
the cylinder-piston device:

```@example 1
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
  ),
)
```


## Simulation

We define
an initial condition
and simulate the system:

```@example 1
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
    :mass => Dtry(
      :p => Dtry(0.0),
    ),
    :tc => Dtry(
      :s => Dtry(1.0),
    ),
  ),
)

h = 0.1    # time step size
t = 200.0  # duration of the simulation
sim = simulate(cpd, midpoint_rule, ic, h, t);
nothing # hide
```

## Plots

We plot the evolution of
the total volume,
and the volume of each compartment:

```@example 1
gas₁₊v = XVar(DtryPath(:gas₁), DtryPath(:v))
gas₂₊v = XVar(DtryPath(:gas₂), DtryPath(:v))
plot_evolution(sim,
  gas₁₊v,
  gas₂₊v,
  gas₁₊v + gas₂₊v;
  ylims=(0, Inf)
)
```

We see that the total volume is conserved.


Next, we plot the evolution of
the total energy,
the kinetic energy of the piston,
the internal energy of the piston, and
the internal energy of each compartment:

```@example 1
plot_evolution(sim,
  "total energy" => total_energy(cpd),
  "piston.mass" => total_energy(mass; box_path=DtryPath(:piston, :mass)),
  "piston.tc" => total_energy(tc; box_path=DtryPath(:piston, :tc)),
  "gas₁" => total_energy(gas; box_path=DtryPath(:gas₁)),
  "gas₂" => total_energy(gas; box_path=DtryPath(:gas₂));
  ylims=(0, Inf),
)
```

We see that the total energy is conserved.


Finally, we plot the evolution of
the total entropy,
the entropy in the piston,
and the entropy in each compartment:

```@example 1
piston₊tc₊s = XVar(DtryPath(:piston, :tc), DtryPath(:s))
gas₁₊s = XVar(DtryPath(:gas₁), DtryPath(:s))
gas₂₊s = XVar(DtryPath(:gas₂), DtryPath(:s))
plot_evolution(sim,
  "total entropy" => total_entropy(cpd),
  piston₊tc₊s,
  gas₁₊s,
  gas₂₊s;
  ylims=(0, Inf),
  legend=:bottomright,
)
```

We see that the total entropy grows monotonically.

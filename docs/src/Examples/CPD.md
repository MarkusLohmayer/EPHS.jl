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


Using the methods
[`point_mass`](@ref),
[`thermal_capacity`](@ref), and
[`ideal_gas`](@ref)
from the [`ComponentLibrary`](@ref),
we define
three [storage components](@ref StorageComponent)
that model
the kinetic energy of the piston,
the internal energy of the piston, and
the internal energy of the gas in each compartment:

```@example 1
mass = point_mass(m=0.5)
tc = thermal_capacity(c₁=1.0, c₂=2.0)
gas = ideal_gas(c₁=1.0, c₂=2.5, v₀=1.0, c=1.5);
nothing # hide
```

To encapsulate the piston
into a reusable unit,
we model it as a separate [composite system](@ref CompositeSystem).
To define
a [reversible component](@ref ReversibleComponent)
that models the coupling between
the two hydraulic energy domains
of the gas on either side of the piston
and the kinetic energy domain of the piston itself,
we use the method [`hkc`](@ref) from the library.
Further,
we use the methods
[`linear_friction`](@ref) and
[`heat_transfer`](@ref)
to define the [irreversible components](@ref IrreversibleComponent).

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
        hkc(a=0.02),
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
        linear_friction(d=0.02),
        Position(3, 3)
      ),
    ),
    :ht₁ => Dtry(
      InnerBox(
        Dtry(
          :s₁ => Dtry(InnerPort(■.s₁)),
          :s₂ => Dtry(InnerPort(■.s)),
        ),
        heat_transfer(h=0.01),
        Position(4, 2)
      ),
    ),
    :ht₂ => Dtry(
      InnerBox(
        Dtry(
          :s₁ => Dtry(InnerPort(■.s₂)),
          :s₂ => Dtry(InnerPort(■.s)),
        ),
        heat_transfer(h=0.01),
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

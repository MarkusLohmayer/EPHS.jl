# Oscillator

In the first part of this example,
we consider a one-dimensional mass-spring oscillator,
and
in the second part,
we reuse this system to form a mass-spring-damper system.

Before we start,
let's load EPHS.jl
and [Plots.jl](https://docs.juliaplots.org/stable/):

```@example 1
using EPHS, Plots
```


## Mass-spring oscillator

Following a bottom-up approach,
we first define the primitive systems,
and then we combine them into a composite system.


### Storage components

We start by defining two [storage components](@ref StorageComponent)
that model storage of potential and kinetic energy:

```@example 1
pe = let
  k = Par(:k, 1.5)                 # stiffness parameter with default value `1.5`
  q = XVar(:q)                     # state variable for displacement of the spring
  I = Dtry(                        # interface
    :q => Dtry(displacement)       # power port defined by its quantity
  )
  E = Const(1/2) * k * q^Const(2)  # energy storage function
  StorageComponent(I, E)
end

ke = let
  m = Par(:m, 1.)
  p = XVar(:p)
  I = Dtry(
    :p => Dtry(momentum)
  )
  E = Const(1/2) * p^Const(2) / m
  StorageComponent(I, E)
end
```

### Reversible component

Next, we define a [reversible component](@ref ReversibleComponent)
that models the reversible coupling of
the potential and kinetic energy domains:

```@example 1
pkc = ReversibleComponent(
  Dtry(
    :q => Dtry(ReversiblePort(FlowPort(displacement, -EVar(:p)))),
    :p => Dtry(ReversiblePort(FlowPort(momentum, EVar(:q))))
  )
)
```

A reversible component is defined by a skew-symmetric relation
among the power variables:

```math
\begin{bmatrix}
  \mathtt{q.f} \\
  \mathtt{p.f}
\end{bmatrix}
\: = \:
\begin{bmatrix}
  0 & -1 \\
  +1 & 0
\end{bmatrix}
\,
\begin{bmatrix}
  \mathtt{q.e} \\
  \mathtt{p.e}
\end{bmatrix}
```


### Composite system

We now define a [`Pattern`](@ref),
which interconnects the three components
(in the only possible way):

```@example 1
osc = CompositeSystem(
  Dtry( # directory of junctions (energy domains)
    :q => Dtry(Junction(displacement, Position(1, 2))),
    :p => Dtry(Junction(momentum, Position(1, 4), exposed=true)),
  ),
  Dtry( # directory of inner boxes (subsystems)
    :pe => Dtry(
      InnerBox(
        Dtry( # interface of box `pe`
          :q => Dtry(InnerPort(■.q)), # assignment of port `pe.q` to junction `q`
        ),
        pe, # filling of the box
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
)
```

To make the system extensible,
the kinetic energy domain is exposed via an outer port.


The semantics of the composite system
is the relation represented by the following equations:

```@example 1
assemble(osc)
```

In the output,
the state variable of a port, say `pe.q`, is shown as `pe.q.x`,
while the flow and effort variables are shown as
`pe.q.f` and `pe.q.e`, respectively.


### Simulation

We define an initial condition as a directory:

```@example 1
ic = Dtry(
  :pe => Dtry(
    :q => Dtry(0.0),
  ),
  :ke => Dtry(
    :p => Dtry(3.0),
  ),
)
```

We use the variational [midpoint rule](@ref midpoint_rule)
to simulate the dynamics of the oscillator:

```@example 1
h = 0.01 # time step size
t = 20.0 # duration of the simulation
sim = simulate(osc, midpoint_rule, ic, h, t);
nothing # hide
```


### Plots

We can plot the evolution of
the displacement [state variable](@ref XVar) `pe.q.x`:

```@example 1
q = XVar(DtryPath(:pe), DtryPath(:q))
plot_evolution(sim, q)
```

We can also plot the evolution of
the total energy, the potential energy, and the kinetic energy:

```@example 1
plot_evolution(sim,
  "total energy" => total_energy(osc),
  "potential energy" => total_energy(pe; box_path=DtryPath(:pe)),
  "kinetic energy" => total_energy(ke; box_path=DtryPath(:ke));
  ylims=(0, Inf), # Plots.jl attribute to set the y axis limits
)
```


## Mass-spring-damper system

We first define the additionally required primitive systems,
and then we combine them with the mass-spring oscillator.


### Storage component

We define a 'thermal capacity',
i.e. a storage component
that models storage of thermal energy:

```@example 1
tc = let
  c₁ = Par(:c₁, 0.5)
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
```


### Irreversible component

Next, we define an [irreversible component](@ref IrreversibleComponent)
that models the irreversible process of
mechanical friction:

```@example 1
mf = let
  d = Par(:d, 0.02)                     # friction coefficient
  p₊e = EVar(:p)                        # effort (velocity)
  s₊e = EVar(:s)                        # effort (temperature (wrt reference environment))
  p₊f = d * p₊e                         # flow (damping force)
  s₊f = -((d * p₊e * p₊e) / (θ₀ + s₊e)) # flow (entropy production)
  IrreversibleComponent(
    Dtry(
      :p => Dtry(IrreversiblePort(momentum, p₊f)),
      :s => Dtry(IrreversiblePort(entropy, s₊f))
    )
  )
end
```

An irreversible component is defined by
a symmetric, non-negative definite relation
among the power variables:

```math
\begin{bmatrix}
  \mathtt{p.f} \\
  \mathtt{s.f}
\end{bmatrix}
\: = \:
\frac{1}{\theta_0} \, d \,
\begin{bmatrix}
  \theta & -\upsilon \\
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

The condition for conservation of energy
is satisfied:

```math
\begin{bmatrix}
  0 \\
  0
\end{bmatrix}
\: = \:
\begin{bmatrix}
  \theta & \upsilon \\
  - \upsilon & \frac{\upsilon^2}{\theta}
\end{bmatrix}
\,
\begin{bmatrix}
  \upsilon \\
  \theta
\end{bmatrix}
```


### Composite system

We can now define a [`Pattern`](@ref),
which interconnects the mass-spring oscillator
and the two primitive systems that we have just defined:

```@example 1
damped_osc = CompositeSystem(
  Dtry(
    :p => Dtry(Junction(momentum, Position(1,2))),
    :s => Dtry(Junction(entropy, Position(1,4))),
  ),
  Dtry(
    :osc => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        osc,
        Position(1,1)
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :s => Dtry(InnerPort(■.s)),
        ),
        mf,
        Position(1,3)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        tc,
        Position(1,5)
      ),
    ),
  )
)
```


The semantics of the composite system
is the relation represented by the following equations:

```@example 1
assemble(damped_osc)
```


### Simulation

```@example 1
ic2 = Dtry(
  :osc => ic,
  :tc => Dtry(
    :s => Dtry(1.0)
  ),
)

sim = simulate(damped_osc, midpoint_rule, ic2, h, t);
nothing # hide
```


### Plots

```@example 1
q = XVar(DtryPath(:osc, :pe), DtryPath(:q))
plot_evolution(sim, q)
```

```@example 1
plot_evolution(sim,
  "total energy" => total_energy(damped_osc),
  "potential energy" => total_energy(pe; box_path=DtryPath(:osc, :pe)),
  "kinetic energy" => total_energy(ke; box_path=DtryPath(:osc, :ke)),
  "thermal energy" => total_energy(tc; box_path=DtryPath(:tc));
  ylims=(0, Inf),
  legend=:topright,
)
```

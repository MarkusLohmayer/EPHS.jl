# Constrained oscillator

In this example,
we model a mechanical oscillator
with two springs connected in series:

```@raw html
<div style="text-align: center;">
    <img src="../../assets/examples/osc_constraint.svg" width="400"/>
</div>
&nbsp;
```

The series connection imposes the constraint that
the forces in both springs must be equal.
Consequently,
the overall displacement
and the potential energy
is distributed between the springs
to satisfy this constraint.

```@setup 1
using EPHS, Plots
```

To not reinvent the wheel, this time we use
[`hookean_spring`](@ref),
[`point_mass`](@ref), and
[`pkc`](@ref)
from the [`ComponentLibrary`](@ref).
Besides these components,
which are defined as in the previous example,
we use [`two_springs_series_connection`](@ref),
which represents the constraint
that the velocities (efforts) of two springs are equal:

```@docs; canonical=false
two_springs_series_connection
```

```@example 1
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
        hookean_spring(k=2.0),
        Position(1, 1)
      ),
    ),
    :pe₂ => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q₂)),
        ),
        hookean_spring(k=6.0),
        Position(3, 1)
      ),
    ),
    :sc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
          :q₂ => Dtry(InnerPort(■.q₂)),
        ),
        two_springs_series_connection,
        Position(2, 2)
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
        point_mass(m=1.0),
        Position(1, 5)
      ),
    ),
  )
)
```

This yields the following system of equations:

```@example 1
assemble(osc_constraint)
```


## Simulation

We define an initial condition,
simulate the system using the midpoint rule,
and plot the resulting displacements:

```@example 1
ic_constraint = Dtry(
  :ke => Dtry(
    :p => Dtry(3.0),
  ),
  :pe₁ => Dtry(
    :q => Dtry(0.0),
  ),
  :pe₂ => Dtry(
    :q => Dtry(0.0),
  )
)
h = 0.1
t = 10
sim = simulate(osc_constraint, midpoint_rule, ic_constraint, h, t)

plot_evolution(
  sim,
  XVar(DtryPath(:pe₁), DtryPath(:q)),
  XVar(DtryPath(:pe₂), DtryPath(:q)),
)
```

Compared to the first spring,
the second spring is stiffer
and hence contributes less to the overall displacement.


## Comparison with unconstrained case

To verify the numerical solution of
the differential-algebraic equation,
we compare the system with the unconstrained oscillator.
The following code assumes that `osc` and `ic` are defined
as in the previous example.

```@setup 1
osc = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(displacement, Position(1, 2))),
    :p => Dtry(Junction(momentum, Position(1, 4), exposed=true)),
  ),
  Dtry(
    :pe => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
        ),
        hookean_spring(k=1.5),
        Position(1, 1)
      ),
    ),
    :ke => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        point_mass(m=1.0),
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

ic = Dtry(
  :pe => Dtry(
    :q => Dtry(0.0),
  ),
  :ke => Dtry(
    :p => Dtry(3.0),
  ),
)
```

```@example 1
comparison = CompositeSystem(
  Dtry(
    :p => Dtry(Junction(momentum, Position(1, 2))),
  ),
  Dtry(
    :osc => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        osc,
        Position(1, 1)
      ),
    ),
    :osc_constraint => Dtry(
      InnerBox(
        Dtry{InnerPort}(),
        osc_constraint,
        Position(1, 4)
      ),
    ),
  )
)
```

We expect that
the overall displacement agrees with the unconstrained case,
since the stiffness coefficients satisfy
the following relation:

```math
\frac{1}{\mathtt{osc\_constraint.pe_1.k}}
\, + \,
\frac{1}{\mathtt{osc\_constraint.pe_2.k}}
\: = \:
\frac{1}{\mathtt{osc.pe.k}}
```

```@example 1
ic_comparison = Dtry(
  :osc => ic,
  :osc_constraint => ic_constraint,
)

sim = simulate(comparison, midpoint_rule, ic_comparison, h, t)

maximum(abs.(
  evolution(
    sim,
    XVar(DtryPath(:osc_constraint, :pe₁), DtryPath(:q)) +
    XVar(DtryPath(:osc_constraint, :pe₂), DtryPath(:q)) -
    XVar(DtryPath(:osc, :pe), DtryPath(:q))
  )
))
```

Indeed, the maximum error is close to
the limits of machine precision.

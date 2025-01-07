# Constrained oscillator

In this example,
we model a mechanical oscillator
with two springs connected in series.
This imposes the constraint that
the forces in both springs must be equal.
Consequently,
the overall displacement
and the potential energy
is distributed between the springs
to satisfy this constraint.

We assume that the components
`pe`, `ke` and `pkc`
from the [Oscillator](@ref) example are already defined.

```@setup 1
using EPHS, Plots

pe = let
  k = Par(:k, 1.5)
  q = XVar(:q)
  I = Dtry(
    :q => Dtry(displacement)
  )
  E = Const(1/2) * k * q^Const(2)
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

pkc = ReversibleComponent(
  Dtry(
    :q => Dtry(ReversiblePort(FlowPort(displacement, -EVar(:p)))),
    :p => Dtry(ReversiblePort(FlowPort(momentum, EVar(:q))))
  )
)
```

We define a reversible component representing the constraint
that the velocities (efforts) of two springs are equal:

```@example 1
c = ReversibleComponent(
  Dtry(
    :q => Dtry(ReversiblePort(FlowPort(displacement, CVar(:λ)))),
    :q₂ => Dtry(ReversiblePort(FlowPort(displacement, -CVar(:λ)))),
    :λ => Dtry(ReversiblePort(Constraint(-EVar(:q) + EVar(:q₂))))
  )
)
```

```math
\begin{bmatrix}
  \mathtt{q.f} \\
  \mathtt{q_2.f} \\
  0
\end{bmatrix}
\: = \:
\begin{bmatrix}
  0 & 0 & +1 \\
  0 & 0 & -1 \\
  -1 & +1 & 0
\end{bmatrix}
\,
\begin{bmatrix}
  \mathtt{q.e} \\
  \mathtt{q_2.e} \\
  \lambda
\end{bmatrix}
```

The constraint variable ``\lambda`` is distributing
the overall (change of) displacement
between the two springs.


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
        pe,
        Position(1, 1)
      ),
    ),
    :pe₂ => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q₂)),
        ),
        pe,
        Position(3, 1)
      ),
    ),
    :c => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
          :q₂ => Dtry(InnerPort(■.q₂)),
        ),
        c,
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
        ke,
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
modify the stiffness parameters,
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
ps = Dtry(
  :pe₁ => Dtry(
    :k => Dtry(2.0),
  ),
  :pe₂ => Dtry(
    :k => Dtry(6.0),
  )
)
h = 0.1
t = 10
sim = simulate(osc_constraint, midpoint_rule, ic_constraint, h, t; ps);

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
We assume that `osc` and `ic` are defined
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

ps = Dtry(
  :osc_constraint => ps,
)

sim = simulate(comparison, midpoint_rule, ic_comparison, h, t; ps)

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

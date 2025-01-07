# [Components](@id ComponentsIntro)

Any system is ultimately composed of primitive systems, also called components.
As reflected in the EPHS.jl logo,
there are three kinds of them:
* Storage components are primitive systems representing **storage of energy**. Inner boxes filled with a storage component are displayed with a **blue** filling.
* Reversible components represent **reversible couplings** between energy domains, **reversible transformations**, or **constraints**.  They conserve energy, entropy, and exergy. Inner boxes filled with a reversible component are displayed with a **green** filling.
* Irreversible components model **irreversible processes**. They conserve energy, produce entropy, and destroy exergy. Inner boxes filled with an irreversible component are displayed with a **red** filling.

In summary,
the blue boxes correspond to the state of a given system,
the green boxes correspond to its reversible dynamics, and
the red boxes correspond to its irreversible dynamics.


To guarantee
a thermodynamically consistent reversible-irreversible splitting
of the dynamics of arbitrarily interconnected composite systems,
systems are defined with respect to
a fixed [exergy](https://en.wikipedia.org/wiki/Exergy) reference environment.
Here,
we assume that the environment contains entropy and volume.
The constant, energy-conjugate, intensive variables
are
the reference temperature ``\theta_0`` and
the reference pressure ``\pi_0``.


Every component has an interface ``I``.
We write
``x \in \mathcal{X}_I``
for the combined state variable, and
``(x, \, f, \, e) \in \mathcal{P}_I``
for the combined state, flow, and effort variables
associated to all its ports.


## Storage components

A storage component is defined by
its interface (of power ports) ``I``,
and an energy function
``E \colon \mathcal{X}_I \to \mathbb{R}``.
Based on the reference environment,
the energy function induces
the corresponding exergy function
``H \colon \mathcal{X}_I \to \mathbb{R}``.

The rate of change of each state variable
is given by
its corresponding flow variable:

```math
\frac{\mathrm{d} x}{\mathrm{d} t}
\: = \:
f
```

Each effort variable
is given by
the partial derivative of
the exergy function
with respect to
the corresponding state variable:

```math
e
\: = \:
\frac{\mathrm{d} H}{\mathrm{d} x}
```

Consequently,
the rate of change of the stored exergy
is given by the pairing of
the effort and flow variables:

```math
\frac{\mathrm{d} H}{\mathrm{d} t}
\: = \:
\langle e \mid f \rangle
```


As a first example,
let's define a [`StorageComponent`](@ref)
representing the potential energy of a Hookean spring:

```@example 1
using EPHS # hide
pe = let
  I = Dtry(                       # interface
    :q => Dtry(displacement)
  )
  q = XVar(:q)                    # state variable
  k = Par(:k, 1.5)                # parameter with default value
  E = Const(1/2) * k * q^Const(2) # energy function
  StorageComponent(I, E)
end
```

The `let` block is used to
contain the Julia variables `I`, `q`, `k`, and `E` within a local scope.

Since `E` does not represent *internal energy*,
the energy and exergy functions are equal.


To complete the picture,
we consider a storage component that models
the internal energy of an ideal gas
contained in a compartment with variable volume:

```@example 1
gas = let
  I = Dtry(
    :s => Dtry(entropy),
    :v => Dtry(volume),
  )
  s = XVar(:s)
  v = XVar(:v)
  c = Par(:c, 3 / 2)
  c₁ = Par(:c₁, 1.0)
  c₂ = Par(:c₂, 2.5)
  v₀ = Par(:v₀, 1.0)
  E = c₁ * exp(s / c₂) * (v₀ / v)^(Const(1) / c)
  StorageComponent(I, E)
end
```

Since the storage component has
state variables representing entropy and volume,
the induced exergy function ``H`` is defined by

```math
H(s, \, v)
\: = \:
E(s, \, v) \, - \, \theta_0 \, s \, + \, \pi_0 * v
```

The effort variables are hence given by
``\mathtt{s.e} = \theta - \theta_0``
and
``\mathtt{v.e} = -(\pi - \pi_0)``,
where
``\theta = \frac{\partial E}{\partial s}``
and
``\pi = -\frac{\partial E}{\partial v}``.

We note that
in the output above,
the (Julia) constants
[`θ₀`](@ref) and [`π₀`](@ref)
are printed as
`ENV.θ` and `ENV.π`, respectively.


## Reversible components

Reversible components can represent
generalized gyrators,
generalized transformers, and
constraints.
While a single component can in general combine
all three aspects,
here we treat them separately.


Reversible components conserve
exergy and
all extensive quantities also present in the environment,
including entropy.
Thus, they also conserve energy.


### Generalized gyrators

The relation defining a generalized gyrator
is of the following form:

```math
f
\: = \:
L(x) \, e
```

For every state ``x``,
the matrix ``L(x)`` is skew-symmetric.
It follows that exergetic power is conserved:

```math
\langle e \mid f \rangle
\: = \:
0
```

To guarantee thermodynamic consistency,
``L`` has to satisfy
some extra conditions
stated in the article.
In particular,
the extensive quantities present in the environment
(entropy and volume)
need to be conserved.


As an example,
we consider a [`ReversibleComponent`](@ref)
that models the coupling
between the kinetic energy domain of a piston
and the two hydraulic energy domains on its front and backside:

```@example 1
hkc = let
  a = Par(:a, 2e-2) # cross-sectional area of cylinder/piston
  p₊e = EVar(:p)
  v₁₊e = EVar(:v₁)
  v₂₊e = EVar(:v₂)
  p₊f = a * (v₁₊e - v₂₊e)
  v₁₊f = -(a * p₊e)
  v₂₊f = a * p₊e
  ReversibleComponent(
    Dtry(
      :p => Dtry(ReversiblePort(FlowPort(momentum, p₊f))),
      :v₁ => Dtry(ReversiblePort(FlowPort(volume, v₁₊f))),
      :v₂ => Dtry(ReversiblePort(FlowPort(volume, v₂₊f))),
    ))
end
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

The condition for conservation of volume is satisfied:

```math
\begin{bmatrix}
  0 \\
  0 \\
  0
\end{bmatrix}
\: = \:
\begin{bmatrix}
   0 & a & -a \\
  -a & 0 &  0 \\
   a & 0 &  0 \\
\end{bmatrix}
\,
\begin{bmatrix}
  0 \\
  -\pi_0 \\
  -\pi_0
\end{bmatrix}
```


### Generalized transformers

The power ports
and their combined flow and effort variables
are split into two parts.
We write
``f = (f_1, \, f_2)`` and
``e = (e_1, \, e_2)``.
The relation defining a generalized transformer
is of the following form:

```math
\begin{bmatrix}
  f_1 \\
  e_2
\end{bmatrix}
\: = \:
\begin{bmatrix}
  0 & -g(x) \\
  g^*(x) & 0
\end{bmatrix}
\,
\begin{bmatrix}
  e_1 \\
  f_2
\end{bmatrix}
```

Again, conservation of exergy follows from skew-symmetry.
Regarding thermodynamic consistency,
conditions on ``g``
(in particular for conservation of entropy and volume)
are stated in the article.


As an example,
we consider a simple mechanical lever:

```@example 1
lever = let
  r = Par(:r, 2.)  # ratio (mechanical advantage of lever)
  q₁₊e = EVar(:q₁)
  q₂₊f = FVar(:q₂)
  q₁₊f = -(r * q₂₊f)
  q₂₊e = r * q₁₊e
  ReversibleComponent(
    Dtry(
      :q₁ => Dtry(ReversiblePort(FlowPort(displacement, q₁₊f))),
      :q₂ => Dtry(ReversiblePort(EffortPort(displacement, q₂₊e)))
    )
  )
end
```

The above defines
a skew-symmetric relation:

```math
\begin{bmatrix}
  \mathtt{q_1.f} \\
  \mathtt{q_2.e}
\end{bmatrix}
\: = \:
\begin{bmatrix}
   0 & a \\
  -a & 0
\end{bmatrix}
\,
\begin{bmatrix}
  \mathtt{q_1.e} \\
  \mathtt{q_2.f}
\end{bmatrix}
```


### Constraints

The relation defining a constraint
is of the following form:

```math
\begin{bmatrix}
  f \\
  0
\end{bmatrix}
\: = \:
\begin{bmatrix}
  0 & C^*(x) \\
  -C(x) & 0
\end{bmatrix}
\,
\begin{bmatrix}
  e \\
  \lambda_c
\end{bmatrix}
```

Here,
the constraint variable (or multiplier) ``\lambda_c``
is determined by
the constraint equation
``0 = C(x) \, e``.


As an example,
we consider a component
that allows to combine two springs in series:

```@example 1
ssc = let
  λ = CVar(:λ)  # constraint variable
  ReversibleComponent(
    Dtry(
      :q => Dtry(ReversiblePort(FlowPort(displacement, λ))),
      :q₂ => Dtry(ReversiblePort(FlowPort(displacement, -λ))),
      :λ => Dtry(ReversiblePort(Constraint(-EVar(:q) + EVar(:q₂))))
    )
  )
end
```

The above defines
a skew-symmetric relation:

```math
\begin{bmatrix}
  \mathtt{q.f} \\
  \mathtt{q_2.f} \\
  0
\end{bmatrix}
\: = \:
\begin{bmatrix}
  0  & 0 &  1 \\
  0  & 0 & -1 \\
  -1 & 1 &  0
\end{bmatrix}
\,
\begin{bmatrix}
  \mathtt{q.e} \\
  \mathtt{q_2.e} \\
  \lambda_c
\end{bmatrix}
```


## Irreversible components

Irreversible components represent irreversible processes.
They have a non-negative exergy destruction rate.
They conserve
energy and
all extensive quantities also present in the environment,
except entropy.
Thus, they have a non-negative entropy production rate.


The relation defining an irreversible component
is of the following form:

```math
f
\: = \:
\frac{1}{\theta_0} \, M(x, e) \, e
```

Here, for every state ``x``
and every effort ``e``,
the matrix ``M(x, \, e)`` is symmetric, non-negative definite.
The symmetry property
corresponds to Onsager's reciprocal relations
and
non-negative definiteness implies
a non-negative exergy destruction rate:

```math
\langle e \mid f \rangle
\: \geq \:
0
```

To guarantee thermodynamic consistency,
``M`` has to satisfy
some extra conditions
stated in the article.
In particular,
energy and
the extensive quantities present in the environment,
except entropy,
need to be conserved.


As an example, we consider
an [`IrreversibleComponent`](@ref)
that models mechanical friction:

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
```

The above defines
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
\: = \:
\begin{bmatrix}
  d \, \upsilon \\
  -\frac{d \, \upsilon^2}{\theta}
\end{bmatrix}
```

Here,
``\upsilon = \mathtt{p.e}``
is the velocity and
``\theta = \theta_{0} + \mathtt{s.e}``
is the absolute temperature
at which kinetic energy is dissipated
into the thermal energy domain.

The condition for conservation of energy is satisfied:

```math
\begin{bmatrix}
  0 \\
  0
\end{bmatrix}
\: = \:
\frac{1}{\theta_{0}} \, d \,
\begin{bmatrix}
  \theta & \upsilon  \\
  - \upsilon & \frac{\upsilon^2}{\theta}
\end{bmatrix}
\,
\begin{bmatrix}
  \upsilon \\
  \theta
\end{bmatrix}
```

# [Patterns](@id PatternsIntro)

Interconnection patterns provide
a simple, graphical syntax
for composing systems.

## Example

A pattern is defined by
a directory of [`Junction`](@ref)s and
a directory of [`InnerBox`](@ref)es.
For graphical display,
junctions and inner boxes can be placed on a grid
by annotating their [`Position`](@ref)s.
Here is an example:

```@example 1
using EPHS # hide
osc = Pattern(
  Dtry( # junctions
    :q => Dtry(Junction(displacement, Position(1, 2))),
    :p => Dtry(Junction(momentum, Position(1, 4), exposed=true)),
  ),
  Dtry( # inner boxes
    :pe => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
        ),
        Position(1, 1)
      ),
    ),
    :ke => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        Position(1, 5)
      ),
    ),
    :pkc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
          :p => Dtry(InnerPort(■.p))
        ),
        Position(1, 3)
      ),
    ),
  )
)
```

The [`Interface`](@ref) of each [`InnerBox`](@ref)
is given by its directory of [`InnerPort`](@ref)s.
Each port is connected to a [`Junction`](@ref)
according to the given [`DtryPath`](@ref).
Since only ports with
the same associated physical [`Quantity`](@ref)
can be connected,
the quantity is assigned only once at the junctions.
The outer ports connected to
the *exposed* junctions
define the outer interface of the pattern.


Let's briefly spell out the physical interpretation:
Junctions represent energy domains.
Here, junction `q` (displacement) on the left represents
the potential energy domain
and junction `p`(momentum) on the right represents
the kinetic energy domain
of a mechanical oscillator.
Inner boxes represent (sub)systems,
which are combined into a composite system
according to the given pattern.
Here, box `pe` represents storage of *potential energy* (spring)
and box `ke` represents storage of *kinetic energy* (mass).
Box `pkc` represents the *potential-kinetic coupling*,
known as the (canonical) symplectic structure in mechanics.


## Composition

To see how patterns compose,
we need to define a second pattern:

```@example 1
damped_osc = Pattern(
  Dtry(
    :p => Dtry(Junction(momentum, Position(1, 2))),
    :s => Dtry(Junction(entropy, Position(1, 4))),
  ),
  Dtry(
    :osc => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        Position(1, 1)
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :s => Dtry(InnerPort(■.s)),
        ),
        Position(1, 3)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        Position(1, 5)
      ),
    ),
  )
)
```

The two patterns are composable since
the outer interface of the first pattern matches
the interface of the inner box `osc`
of the second pattern:

```@example 1
interface(osc) == interface(damped_osc, ■.osc)
```

In this way,
a (reversible) oscillator model
can be reused as a subsystem of
a damped oscillator model.
Box `mf` represents *mechanical friction* and
box `tc` represents a *thermal capacity*
that stores the dissipated energy.

The rest of this page is just an exercise
to understand how composition works.
It does not reflect how to use the framework in practice.

Patterns are composable
whenever interfaces match.
This is made precise by demonstrating that
the syntax forms a directory-multicategory with
interfaces as objects and patterns as morphisms.
However, this mathematical framework does not include
positions for graphical display.
Breaking down a complex system into small, manageable parts
is meaningful only if
the parts can be unambiguously composed,
yielding again the original, complex system.
The multicategory structure guarantees just that.
As we do not intend to work directly with
the flat, monolithic description,
there is basically no need to display it graphically.

To illustrate visually what happens when we compose
the two patterns defined above,
we manually define the result,
choosing the positions at will:

```@example 1
damped_osc_flat = Pattern(
  Dtry(
    :p => Dtry(Junction(momentum, Position(1, 4))),
    :s => Dtry(Junction(entropy, Position(0, 5))),
    :osc => Dtry(
      :q => Dtry(Junction(displacement, Position(1, 2))),
    ),
  ),
  Dtry(
    :osc => Dtry(
      :pe => Dtry(
        InnerBox(
          Dtry(
            :q => Dtry(InnerPort(■.osc.q)),
          ),
          Position(1, 1)
        ),
      ),
      :ke => Dtry(
        InnerBox(
          Dtry(
            :p => Dtry(InnerPort(■.p)),
          ),
          Position(1, 5)
        ),
      ),
      :pkc => Dtry(
        InnerBox(
          Dtry(
            :q => Dtry(InnerPort(■.osc.q)),
            :p => Dtry(InnerPort(■.p))
          ),
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
        Position(0, 4)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        Position(0, 6)
      ),
    ),
  )
)
```

We can now assert that this is exactly
what the mathematical framework gives us:

```@example 1
osc = Pattern{Nothing,Nothing}(osc)
damped_osc = Pattern{Nothing,Nothing}(damped_osc)
damped_osc_flat = Pattern{Nothing,Nothing}(damped_osc_flat)

id_mf = identity(interface(damped_osc, ■.mf))
id_tc = identity(interface(damped_osc, ■.tc))

compose(damped_osc, Dtry(
  :osc => Dtry(osc),
  :mf => Dtry(id_mf),
  :tc => Dtry(id_tc),
)) == damped_osc_flat
```

First,
we reduced the three patterns to
their mathematical content as morphisms.
by reconstructing them with
the [`Pattern{Nothing,Nothing}(::Pattern)`](@ref) constructor.
Then,
we constructed identity patterns/morphisms for
the boxes/interfaces/objects `mf` and `tc`.
Finally,
we [`compose`](@ref)d the morphism `damped_osc`
with the morphism `osc` and the two identity morphisms.
This indeed resulted in the morphism `damped_osc_flat`.

To conclude,
it is straightforward to work with a hierarchy of simple patterns,
rather than with a single complex pattern,
because composition is uniquely defined and associative.
Two adjacent levels of description are related,
as they share interfaces in common.
For each pattern on the lower-level,
the outer box matches with
an inner box of the pattern on the higher level.
To form the composed/flattened pattern,
for each port of each shared interface,
the two assigned junctions
(one on the lower-level and one on the higher-level)
are identified.


More information about
the Julia implementation of patterns
is provided in the [reference](@ref Patterns).


## Functorial semantics

Each port has associated variables,
like the flow and effort variables known from bond graphs.
At each junction, the variables of the connected ports
satisfy a relation,
similar to 0-junctions in bond graphs.

The outer box of a pattern
as well as each of its inner boxes
each represent an interface,
given by a directory of ports,
see [`interface(::Pattern)`](@ref)
and [`interface(::Pattern, ::DtryPath)`](@ref).
Since each port is connected to exactly one junction,
the mathematical content of a pattern is
a partition of all involved (inner and outer) ports.
For instance, in the above pattern, the inner ports
`osc.pkc.p`, `osc.ke.p`, and `mf.p`
constitute one of the three parts (or junctions).

To use a pattern as a means to
interconnect systems
(whose interfaces match the inner boxes)
into a composite system
(whose interface matches the outer box),
the mathematical content of the pattern
needs to be translated into
a relation among the associated port variables.

State ports have a state variable
and power ports additionally have
a flow variable and an effort variable.
Given a power port named ``p``,
its state, flow, and effort variables are denoted by
``p \mathtt{.x}``,
``p \mathtt{.f}``, and
``p \mathtt{.e}``, respectively.
Considering for instance an interface ``I``
with two power ports named
``\mathtt{p_1}`` and ``\mathtt{p_2}``,
as well as a state port named ``\mathtt{s}``,
its associated bundle of port variables
``\mathcal{P}_I``
has seven port variables:

```math
\left(
  \mathtt{p_1.x}, \, \mathtt{p_1.f}, \, \mathtt{p_1.e}, \,
  \mathtt{p_2.x}, \, \mathtt{p_2.f}, \, \mathtt{p_2.e}, \,
  \mathtt{s.x}
\right)
\, \in \,
\mathcal{P}_I
```

The port variables form
a [vector bundle](https://en.wikipedia.org/wiki/Vector_bundle),
where the state variables live in the base space and
the flow/effort variables live in the corresponding tangent/cotangent spaces.
For the moment, we simply assume that all port variables are real-valued.
We can thus identify
``\mathcal{P}_I \cong \mathbb{R}^7``.


At every junction,
the following holds:

1. **Equality of state**: the state variables of all connected ports are equal.
2. **Equality of effort**: the effort variables of all connected power ports are equal.
3. **Equality of net flow**: the sum of the flow variables of all connected inner power ports is equal to the sum of the flow variables of all connected outer power ports.

In the remaining part of this page,
we discuss some important mathematical aspects,
which should be addressed in more detail in a future paper.


The translation
from combinatorial syntax
to relational semantics
is mathematically understood as a functor
``F \colon \mathrm{Syntax} \to \mathrm{Rel}``.
On objects,
it sends an interface ``I``
to its bundle of port variables ``F(I) = \mathcal{P}_I``.
On morphisms,
it sends a pattern ``f``
to the relation ``F(f)``,
defined by equality of state,
equality of effort,
and equality of net flow.

For instance,
let's consider a pattern ``f`` with three inner boxes
named ``\mathtt{a}``, ``\mathtt{b}``, and ``\mathtt{c}``.
Let ``I`` denote the interface of its outer box,
called the *outer interface* of ``f``.
Further,
Let ``I_a``, ``I_b``, and ``I_c`` denote
the interfaces of the inner boxes.
We write
``I_i = \sum[ a \mapsto I_a, \, b \mapsto I_b, \, c \mapsto I_c ]``
for the combined interface,
called the *inner interface* of ``f``.
Assuming that
``I_a`` has two ports named ``\mathtt{q}`` and ``\mathtt{p}``,
``I_b`` has two ports named ``\mathtt{p}`` and ``\mathtt{s}``, and
``I_c`` has one port named ``\mathtt{s}``,
the inner interface ``I_i`` has
five ports named
``\mathtt{a.q}``, ``\mathtt{a.p}``,
``\mathtt{b.p}``, ``\mathtt{b.s}``, and
``\mathtt{c.s}``.
Here, ``\sum`` denotes the *named sum*
in the *directory-multicategory* ``\mathrm{Syntax}``.
In contrast to a symmetric monoidal category (SMC),
a directory-multicategory uses human-friendly names
to combine objects or morphisms in parallel.
This means that we don't
have to worry about
parentheses and coherence isomorphisms such as
``(I_a \oplus I_b) \oplus I_c \cong I_a \oplus (I_b \oplus I_c)``,
where
``\oplus`` denotes the binary [monoidal product](https://en.wikipedia.org/wiki/Monoidal_category) of the equivalent SMC.

As a functor,
``F`` preserves source and target of morphisms.
For the pattern ``f \colon I_i \to I``,
we hence get a relation of the form
``F(f) \colon F(I_i) \to F(I)``.
To be more precise,
we think of ``F`` as
a *lax directory-multifunctor*
to the directory-multicategory ``\mathrm{Rel}``,
cf. [lax monoidal functor](https://en.wikipedia.org/wiki/Monoidal_functor).
This means that ``F`` comes with
a natural transformation of the form
``\sum[ a \mapsto F(I_a), \, b \mapsto F(I_b), \, c \mapsto F(I_c)] \to F(\sum[ a \mapsto I_a, \, b \mapsto I_b, \, c \mapsto I_c ])``
for every parallel combination of interfaces.
Again, we don't have to worry about
the difference between, say,
``((\mathtt{a.q.x}, \, \mathtt{a.p.x}), \, (\mathtt{b.p.x}, \, \mathtt{b.s.x}))``
and
``(((\mathtt{a.q.x}, \, \mathtt{a.p.x}), \, \mathtt{b.p.x}), \, \mathtt{b.s.x})``,
since the names already do the job.
Precomposing (or 'whiskering') ``F``
with the 'lax' transformation,
yields the semantics of the pattern ``f``,
given by
a morphism in ``\mathrm{Rel}`` of the form
``\sum[ a \mapsto F(I_a), \, b \mapsto F(I_b), \, c \mapsto F(I_c)] \to F(I)``.
This is simply
a relation among
the port variables of all involved interfaces,
written in a way that distinguishes between
the subsystems on one side and
the composite system on the other side.

As a functor,
``F`` also preserves composite morphisms.
This means that the semantics of patterns
is well-behaved in the sense that
we can flatten a hierarchy of patterns
and then ask for
the relation associated to the composed pattern,
or we can ask for
the relation associated to each pattern in the hierarchy
and then compose those relations.
Either way results in the same relation.

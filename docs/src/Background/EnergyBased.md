# Energy-based modeling

## Hamiltonian systems

Hamiltonian systems provide an energy-based mathematical formalism for classical mechanics, and also electromagnetism.
A Hamiltonian system is essentially defined by

* an **energy function** ("the Hamiltonian")

    * amount of energy in the system as a function of the state
    * models constitutive behavior of energy storage in the system

* **symplectic structure**

    * models reversible energy exchange (potential energy <--> kinetic energy)
    * canonically defined on cotangent bundle, i.e. when state is given by configuration variables ("generalized coordinates") and corresponding momenta
    * structure guarantees conservation of energy (first law of thermodynamics)

* generalizations of symplectic structure

    * Poisson structures allow additional invariants besides energy
    * presymplectic structures allow algebraic constraints
    * Dirac structures allow both additional invariants and algebraic constraints

Invariants, i.e. functions of the state that evolve as constants in time,
are closely linked to symmetries of the system
([Noether's theorem](https://en.wikipedia.org/wiki/Noether%27s_theorem)).


## Thermodynamic modeling

As the most famous parts of thermodynamics,
the **first and second law** state that
the total energy is conserved,
and entropy production is non-negative.

In the non-equilibrium case,
thermodynamics assumes a splitting of the dynamics into
a reversible and an irreversible part.
This is made clear in particular by the metriplectic or GENERIC framework,
where the reversible part is modeled as a Hamiltonian system,
which inherently conserves energy,
and the irreversible part is modeled as a (generalized) gradient system,
which inherently evolves toward maximum entropy.
The first and second law are then guaranteed if

* the reversible dynamics conserve entropy
* the irreversible dynamics conserve energy

Compared to a mechanical/Hamiltonian system,
the additional irreversible part essentially summarizes
the "subscale content" of the model.
Since the part is not "fully resolved",
the dynamics is irreversible.
Essentially, it cannot happen backwards in time,
for a lack of information or precision
(uncertainty, usually amplified by
the "chaotic nature of the subscale content").
The subscale energy content is traditionally called "internal energy".
It is a function of the (macroscopic) entropy,
similar to how momentum is the extensive variable
to express the kinetic energy of a mechanical system.
The corresponding intensive variables are given by
the differential of the respective energy function.
The intensive counterpart of entropy is the absolute temperature
and the intensive counterpart of momentum is the velocity.

Especially in many engineering applications,
the irreversible dynamics can be modeled within the framework of
*Linear Irreversible Thermodynamics* (LIT),
which is characterized by its assumption of local thermodynamic equilibrium:

* sufficiently macroscopic level of description that warrants the use of local temperature as a meaningful variable
* use of "force-flux pairs" to model irreversible processes (e.g. temperature difference (force) causes a heat flux)
* relation between thermodynamic forces and fluxes has Onsager symmetry

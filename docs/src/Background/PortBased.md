# Port-based modeling

Port-based modeling is concerned with networks of open physical systems that exchange energy via (power) ports.
In the context of physical modeling, the use of modularity to handle complexity has been pioneered for instance by Kron's "Method of Tearing" (aka Diakoptics).


## Bond graphs

Bond graphs provide a **graphical notation** for models of physical systems:

* nodes/elements are primitive subsystems

    * generalized capacitors, inductors, resistors, transformers, gyrators, etc.
    * 0-junctions and 1-junctions as generalized Kirchhoff circuit laws

* edges/bonds model energy exchange between subsystems


Bond graphs provide an energy-based alternative to "linear graphs",
as known from electrical circuit diagrams.
While linear graphs are also commonly used in other physical domains, such as acoustics, the energy-based approach of bond graphs makes them well-suited for "multi-physical models".


## Port-Hamiltonian systems

Inspired by bond graphs,
port-Hamiltonian systems provide a framework
which uses Dirac structures
not only to allow for dynamical invariants and algebraic constraints,
but also to add external power ports.
The Dirac structure models
the lossless exchange of energy within the system
and across its interface, given by the external ports.
Some of these ports may however also be "closed" internally
by a "resistive relation".
This models a dissipative (as opposed to a lossless) dynamics,
which removes energy from the system.

Various classes of ODEs/DAEs/PDEs/PDAEs with (external) ports
are port-Hamiltonian, meaning that

* each class is closed under power-preserving interconnection (composition)

* structure guarantees passivity and power balance

    * stored power + dissipated power = power supplied via ports
    * dissipated power ≥ 0

A power-preserving interconnection is given by an "interconnecting Dirac structure",
which is composed with the Dirac structures of the subsystems
to define the Dirac structure of the composed system.

# [Current limitations and a vision for the future](@id Vision)

A major limitation of EPHS.jl is
its computer algebra system (CAS)
used to express equations/relations.
At present, the CAS assumes that
port variables are real-valued scalars,
rather than elements of some vector space,
or even more generally, of a Lie group or Lie algebra.

As applications that require a more general CAS,
we have theoretically studied
multibody systems (formulated based on the Lie group of Euclidean isometries)
as well as
fluid and plasma models (formulated using exterior calculus):

* [Exergetic port-Hamiltonian systems for multibody dynamics](https://www.researchgate.net/publication/385560090_Exergetic_port-Hamiltonian_systems_for_multibody_dynamics)
* [Energy-based, geometric, and compositional formulation of fluid and plasma models](https://www.researchgate.net/publication/396336370_Energy-based_geometric_and_compositional_formulation_of_fluid_and_plasma_models)


!!! tip
    The main goal of this proof of concept is
    to encourage the emergence of
    one or more community-driven port-Hamiltonian software frameworks.
    Through united effort,
    the well-recognized strengths of port-Hamiltonian systems,
    such as modularity and structure preservation,
    can move beyond theory
    and begin to deliver practical impact.
    This work is guided by the strong conviction that,
    for port-Hamiltonian modeling to truly gain traction,
    composability must not only be theoretically possible,
    but also seamless and intuitive in practice.

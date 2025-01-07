# The approach behind EPHS.jl

## Compositionality

EPHS formalizes modularity and hierarchical nesting of systems
based on a simple, graphical syntax,
using ideas from (applied) [category theory](https://en.wikipedia.org/wiki/Category_theory).

* explicit separation of syntax and semantics (as different categories)

    * compatibility of composition operations for [interconnection patterns (syntax)](@ref PatternsIntro) and systems/relations (semantics) is a functor property (cf. [Lawvere's functorial semantics](https://ncatlab.org/nlab/show/Functorial+Semantics+of+Algebraic+Theories))

* use of [*directories*](@ref DirectoriesIntro) as a data structure for hierarchically-organized information

    * directories have the algebraic structure of a monad
    * directory-multicategories essentially are a strictification of symmetric monoidal categories
    * idea: combine objects (system interfaces and systems) and morphisms (interconnection patterns and composite systems) in parallel, using human-friendly names instead of a binary [monoidal product](https://en.wikipedia.org/wiki/Monoidal_category) (i.e. a bifunctor that has to satisfy coherence diagrams)

While the jargon of category theory is likely not attractive to users,
designing a compositional framework with these ideas in mind
helps to arrive at an ultimately quite simple setup.


## Thermodynamic modeling

Whenever the hierarchy of nested subsystems is (made) flat,
the remaining subsystems are primitive [components](@ref ComponentsIntro).
Inspired by the metriplectic or GENERIC framework,
the relations that define (the behavior of) the components
have a structure that implies
a thermodynamically consistent reversible-irreversible splitting.
It follows that the first law and second law hold for
arbitrarily composed EPHS models.
In the jargon of port-Hamiltonian systems,
this is achieved first and foremost by
replacing the energy storage function (or "Hamiltonian")
with an [exergy](https://en.wikipedia.org/wiki/Exergy) storage function (also called available energy),
as discussed in more detail in the [first EPHS paper](https://www.researchgate.net/publication/355569377_Exergetic_port-Hamiltonian_systems_modelling_basics).


Expressions in the graphical syntax (interconnection patterns)
can be directly interpreted as energy/exergy flow diagrams,
as used in (engineering) thermodynamics
(or "thermodynamic optimization" or "exergy analysis").

# EPHS.jl

**A compositional, energy-based software framework for modeling mechanical, electromagnetic and thermodynamic systems**

EPHS.jl lets you represent physical systems as **composable energy-flow diagrams** grounded in the **port-Hamiltonian** approach.
Crucially, the graphical syntax and the port-Hamiltonian semantics compose in compatible ways, enabling seamless **hierarchical (de)composition of systems**.
Additional structural properties guarantee not just passivity, but thermodynamic consistency (1st & 2nd law).
The primary goal is to **make complex energy-based models easier to build, understand, reuse, and refactor** without sacrificing mathematical rigor.

## Highlights

- Hierarchical model structure to manage complexity  
- Simple reuse of models at all levels of abstraction  
- Thermodynamic consistency follows recursively from consistency of subsystems  

## Documentation

📘 **Online documentation:**  
https://MarkusLohmayer.github.io/EPHS.jl


## Vision

- Extend the underlying computer algebra system to multiple theories (Lie groups and algebras, exterior calculus)
- Add capabilities for optimization of symbolic expressions and theorem proofing using (slotted) e-graphs
- Provide tooling for data-driven parameter identification
- Implement various numerical integrators as natural transformations
- Demonstrate that the port-Hamiltonian modeling language provides a well-suited target language for generative AI in physical modeling


## Peer-reviewed journal publications

* [Exergetic Port-Hamiltonian Systems Modeling Language](https://www.researchgate.net/publication/398910031_Exergetic_Port-Hamiltonian_systems_modeling_language)
* [Exergetic port-Hamiltonian systems for multibody dynamics](https://www.researchgate.net/publication/385560090_Exergetic_port-Hamiltonian_systems_for_multibody_dynamics)
* [Energy-based, geometric, and compositional formulation of fluid and plasma models](https://www.researchgate.net/publication/396336370_Energy-based_geometric_and_compositional_formulation_of_fluid_and_plasma_models)
* [Exergetic port-Hamiltonian systems: modelling basics](https://www.researchgate.net/publication/355569377_Exergetic_port-Hamiltonian_systems_modelling_basics)


## Preprints

* [Directories: A Convenient and Well-Behaved Formalism for Hierarchical Organization in Categorical Systems Theory](https://www.researchgate.net/publication/391246276_Directories_A_Convenient_and_Well-Behaved_Formalism_for_Hierarchical_Organization_in_Categorical_Systems_Theory)

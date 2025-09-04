### A Pluto.jl notebook ###
# v0.20.8

using Markdown
using InteractiveUtils

# ╔═╡ 88752a0c-de2e-11ef-1572-c10479e38922
begin
	import Pkg
	Pkg.activate("..")
	using Revise
	using Test
	using EPHS
	using Plots
	using AbstractTrees
end

# ╔═╡ 617a56bb-2793-48ae-b845-b802fe8d3454
html"<button onclick='present()'>Toggle presentation mode</button>"

# ╔═╡ 2001e3e6-3d5a-40ee-964f-2fe1fbff3ebe
md"""
# EPHS.jl - A compositional, energy-based software framework for modeling mechanical, electromagnetic and thermodynamic systems
"""

# ╔═╡ 0296f687-7e3f-471e-b431-a63330976154
md"""
## Energy-based modeling

* **Hamiltonian system**s (classical mechanics and electromagnetism)
    * **energy function** ("Hamiltonian")
    * **symplectic structure** (or Poisson-/presymplectic-/Dirac structure)
* Thermodynamic modeling (with focus on CIT/LIT)
    * **first and second law**
    * **reversible-irreversible splitting** of dynamics
        * reversible dynamics
          * inherently conserves energy
          * doesn't dissipate (no entropy production)
          * satisfies integrability condition
        * irreversible dynamics
          * inherently produces entropy
          * conserves energy
          * satisfies Onsager symmetry
    * metriplectic/GENERIC framework (class of state space ODEs/PDEs)
"""

# ╔═╡ 08f633bc-0e00-4fb6-9464-b48db005c7e9
md"""
## Port-based modeling

* networks of open systems that exchange energy via their ports
  * reticulation, modularity (handling complexity)
* bond graphs
  * graph-like notation
    * nodes: subsystems are primitive elements (`C`,`L`,`R`,`TF`,`GY`)
    * edges: model energy exchange between elements
* port-Hamiltonian systems
  * classes of state space ODEs/DAEs/PDEs/PDAEs with (external) ports
  * each class is closed under power-preserving interconnection
  * structure guarantees passivity, i.e. $\dot{H}(x(t)) \leq \langle y(t) \mid u(t) \rangle$
"""

# ╔═╡ f178a258-4c18-4e90-bc6a-04628fe03757
md"""
## Bond graphs vs port-Hamiltonian systems

* bond graphs
  * subsystems are explicit and primitve/flat
  * interconnection realized through graphical notation
  * bond graphs are not inherently composable
* port-Hamiltonian systems
  * subsystems are not explicit (only $H$, $J$, $R$)
  * PHS can be interconnected (or "composed") through 'interconnecting Dirac structure'
"""

# ╔═╡ 4dd43ce4-9f43-41fb-b4de-45d2b33ff79c
md"""
## Exergetic port-Hamiltonian systems modeling language

* subsystems are explicit and can be hierarchically nested
* interconnection realized through composable graphical syntax
  * simpler version of (open) bond graphs
* inherently composable
  * syntax forms a multicategory
    * objects: system interfaces
    * morphisms: interconnection patterns
    * when interfaces match, composition of patterns is uniquely defined and associative
  * functorial semantics
    * objects: bundles of port variables
    * morphisms: relations between bundles of port-variables
* thermodynamic modeling
  * reversible-irreversible splitting consistent with first and second laws
  * syntactic expressions are energy/exergy flow diagrams (as used in engineering thermodynamics)
"""

# ╔═╡ 1a3f9083-6169-4327-84f9-6d62332e9aba
md"""
## Directories: a well-behaved formalism for hierarchical organization in categorical systems theory

**A directory contains values associated to a hierarchically-defined system**

Example: (real-valued) initial conditions
"""

# ╔═╡ 49d533ca-3ced-4814-983e-3c7c69adfe31
ic = Dtry(
  :osc => Dtry(
    :pe => Dtry(
      :q => Dtry(1.0),
    ),
    :ke => Dtry(
      :p => Dtry(0.0),
    ),
  ),
  :tc => Dtry(
    :s => Dtry(16.56)
  ),
)

# ╔═╡ 0ebf6384-77f4-4c49-8faf-17b8549f5ad0
ic.osc    # access subdirectory named `osc`

# ╔═╡ 1233a4cf-4871-4852-a332-418dff69e405
ic.tc.s   # access primitive subdirectory

# ╔═╡ 3164fe5b-cd32-4f3e-bb60-9cc0b5d73ecb
ic.tc.s[] # directly access corresponding value

# ╔═╡ aa6e9e66-00eb-46ee-8607-f80687ce7ff4
ic[■.osc.pe.q]  # access value via complete path

# ╔═╡ c4f2a81e-684e-4b56-a0b4-6ed112a6da40
md"""
### Monad structure

- `Dtry : T -> Dtry{T}`
- `flatten : Dtry{{Dtry{T}}} -> Dtry{T}`
"""

# ╔═╡ d4d14845-8c6c-4c2b-9f3b-fe893c275d17
Dtry("hello world") # monad unit wraps a value as a primitive directory

# ╔═╡ d71a7ecb-e8f6-4f7b-96ec-4798cce74c23
dd = Dtry(
  :oszillator => Dtry(ic.osc), # directory as value!
  :thermische_kapazitaet => Dtry(ic.tc)
)

# ╔═╡ 2f7e2627-84cd-4d6b-906d-58309ecc8849
flatten(dd) # monad multiplication

# ╔═╡ 1110a995-96ed-4d27-a17e-a07462451cd6
md"""
## Syntax is a `Dtry`-multicategory

* objects: system interfaces (directories of ports)
* morphisms: interconnection patterns
* can combine systems/interfaces/patterns in parallel via directories
* composition: hierarchical nesting of systems/patterns
"""

# ╔═╡ 58418029-d0bc-42e0-b818-67356268f662
md"""
Interconnection pattern of a mechanical oscillator model:
* pe - potential energy (storage)
* ke - kinetic energy (storage)
* pkc - potential-kinetic coupling (reversible dynamics, canonical symplectic structure)
"""

# ╔═╡ 2f61d0a9-eb87-42c3-8b4b-98ff28861d53
pattern_osc = Pattern(
  Dtry( # directory of junctions
    :q => Dtry(
		Junction(
			displacement,
			Position(1,2)
		)
	),
    :p => Dtry(
		Junction(
			momentum,
			Position(1,4),
			exposed=true
		)
	),
  ),
  Dtry( # directory of inner boxes (subsystems)
    :pe => Dtry(
      InnerBox(
        Dtry( # directory of ports
          :q => Dtry(InnerPort(■.q)),
        ),
        Position(1,1)
      ),
    ),
    :ke => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        Position(1,5)
      ),
    ),
    :pkc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
          :p => Dtry(InnerPort(■.p))
        ),
        Position(1,3)
      ),
    ),
  )
)

# ╔═╡ e42e187c-4a8f-4246-8241-db864496391a
pattern_osc |> print

# ╔═╡ 20cba0e2-dd7f-457d-b612-b45ecce76657
pattern_damped_osc = Pattern(
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
        Position(1,1)
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :s => Dtry(InnerPort(■.s)),
        ),
        Position(1,3)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        Position(1,5)
      ),
    ),
  )
)

# ╔═╡ 3f0e20ac-fa7a-4af8-a65f-b0e27e4ee737
interface(pattern_damped_osc, ■.osc) == interface(pattern_osc)

# ╔═╡ d605e9e6-5e5c-44f0-b471-156ed5829b3e
pattern_damped_osc_flat = Pattern(
  Dtry(
    :p => Dtry(Junction(momentum, Position(1,4))),
    :s => Dtry(Junction(entropy, Position(0,5))),
    :osc => Dtry(
      :q => Dtry(Junction(displacement, Position(1,2))),
    ),
  ),
  Dtry(
    :osc => Dtry(
      :pe => Dtry(
        InnerBox(
          Dtry(
            :q => Dtry(InnerPort(■.osc.q)),
          ),
          Position(1,1)
        ),
      ),
      :ke => Dtry(
        InnerBox(
          Dtry(
            :p => Dtry(InnerPort(■.p)),
          ),
          Position(1,5)
        ),
      ),
      :pkc => Dtry(
        InnerBox(
          Dtry(
            :q => Dtry(InnerPort(■.osc.q)),
            :p => Dtry(InnerPort(■.p))
          ),
          Position(1,3)
        ),
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :s => Dtry(InnerPort(■.s)),
        ),
        Position(0,4)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        Position(0,6)
      ),
    ),
  )
)

# ╔═╡ f87e71e4-be18-4c2e-8a9e-f20e731570d9
let
	P = Pattern{Nothing,Nothing}
	id_mf = identity(interface(pattern_damped_osc, ■.mf))
	id_tc = identity(interface(pattern_damped_osc, ■.tc))
	@test compose(P(pattern_damped_osc), Dtry(
		:osc => Dtry(P(pattern_osc)),
  		:mf => Dtry(id_mf),
  		:tc => Dtry(id_tc),
	)) == P(pattern_damped_osc_flat)
end

# ╔═╡ 73399877-352c-411c-a3d3-77b6a6d21cb6
pattern_damped_osc_flat |> print

# ╔═╡ 1bd2a462-2f4a-4cdb-b1e3-17ed02454839
md"""
## Semantics

* Every system implies a relation
* A system is either primitive or composed of other systems:
"""

# ╔═╡ a4fa5ecb-6a82-43db-8fef-8a106684751e
begin
	AbstractTrees.children(d::DataType) = subtypes(d)
	print_tree(AbstractSystem)
end

# ╔═╡ dc83fca3-35b9-4f7e-af0b-004490671439
md"""

### Components

There are three types of primitive systems, also called 'components'
"""

# ╔═╡ 7056eb21-ba88-47c2-a053-4913d8f0f013
hookean_spring(k=1.5)

# ╔═╡ e5def323-17a6-441b-bf5c-1241f46e3436
pkc

# ╔═╡ 7e0bd601-9a95-47ea-9ba4-0a8d297d2acc
linear_friction(d=0.02)

# ╔═╡ 481fa23f-698c-4bd3-addf-057167fadd1c
md"""
### Composite systems

* A composite system is given by an interconnection pattern, where each inner box is filled by a system
* Patterns also imply a relation (functorial semantics of syntax)
* Relation implied by composite system is given by combining the relations implied by the subsystems in parallel and pre-composing with the relation implied by the pattern
"""

# ╔═╡ d095d44c-c04a-43fa-985a-c358db7280d7
pkc

# ╔═╡ e3c50826-b007-4b1b-9283-41c4862c5d0f
osc = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(displacement, Position(1,2))),
    :p => Dtry(Junction(momentum, Position(1,4), exposed=true)),
  ),
  Dtry(
    :pe => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
        ),
        hookean_spring(k=1.5),
        Position(1,1)
      ),
    ),
    :ke => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        point_mass(m=1.0),
        Position(1,5)
      ),
    ),
    :pkc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
          :p => Dtry(InnerPort(■.p))
        ),
        pkc,
        Position(1,3)
      ),
    ),
  )
)

# ╔═╡ ba8d0e88-78fc-4587-99af-08a2ef83e91c
assemble(osc) |> equations |> print

# ╔═╡ f67baa05-26d3-4639-b8ff-b801f2ddd47f
osc_damped = CompositeSystem(
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
        osc, # nested composite system (undamped oscillator)
        Position(1,1)
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :s => Dtry(InnerPort(■.s)),
        ),
        linear_friction(d=0.02),
        Position(1,3)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        thermal_capacity(c₁=1.0, c₂=2.0),
        Position(1,5)
      ),
    ),
  )
)

# ╔═╡ fed755ff-03b6-42bc-956a-0f950025553b
osc_damped |> print

# ╔═╡ c0745d5d-56a1-40ff-8635-878d0a45ae65
assemble(osc_damped) |> equations |> print

# ╔═╡ d02064ad-695a-43f0-bc2e-251f216c15b4
md"""
#### Let's run a simulation

First, we set an initial condition for the hierarchically defined system:
"""

# ╔═╡ c4a516b3-dec7-4ad2-b146-baed0bb95e67
sim = simulate(osc_damped, midpoint_rule, ic, 0.01, 20);

# ╔═╡ 4c226f67-e5ad-453b-8e4e-99a5aafbdd7c
ic

# ╔═╡ 6ab4b77a-ead0-4d5c-be18-865223cb202c
assemble(osc) |> midpoint_rule

# ╔═╡ 984df1d6-340e-4069-a55c-8d11899ab490
let
q = XVar(DtryPath(:osc, :pe), DtryPath(:q))
plot_evolution(sim, q)
end

# ╔═╡ e5897d2d-fcf4-4895-8e5e-d52c59d6f99f
let
s = XVar(DtryPath(:tc), DtryPath(:s))
plot_evolution(sim, s)
end

# ╔═╡ Cell order:
# ╟─617a56bb-2793-48ae-b845-b802fe8d3454
# ╟─2001e3e6-3d5a-40ee-964f-2fe1fbff3ebe
# ╠═88752a0c-de2e-11ef-1572-c10479e38922
# ╟─0296f687-7e3f-471e-b431-a63330976154
# ╟─08f633bc-0e00-4fb6-9464-b48db005c7e9
# ╟─f178a258-4c18-4e90-bc6a-04628fe03757
# ╟─4dd43ce4-9f43-41fb-b4de-45d2b33ff79c
# ╟─1a3f9083-6169-4327-84f9-6d62332e9aba
# ╠═49d533ca-3ced-4814-983e-3c7c69adfe31
# ╠═0ebf6384-77f4-4c49-8faf-17b8549f5ad0
# ╠═1233a4cf-4871-4852-a332-418dff69e405
# ╠═3164fe5b-cd32-4f3e-bb60-9cc0b5d73ecb
# ╠═aa6e9e66-00eb-46ee-8607-f80687ce7ff4
# ╟─c4f2a81e-684e-4b56-a0b4-6ed112a6da40
# ╠═d4d14845-8c6c-4c2b-9f3b-fe893c275d17
# ╠═d71a7ecb-e8f6-4f7b-96ec-4798cce74c23
# ╠═2f7e2627-84cd-4d6b-906d-58309ecc8849
# ╟─1110a995-96ed-4d27-a17e-a07462451cd6
# ╠═e42e187c-4a8f-4246-8241-db864496391a
# ╟─58418029-d0bc-42e0-b818-67356268f662
# ╟─2f61d0a9-eb87-42c3-8b4b-98ff28861d53
# ╟─20cba0e2-dd7f-457d-b612-b45ecce76657
# ╠═3f0e20ac-fa7a-4af8-a65f-b0e27e4ee737
# ╟─d605e9e6-5e5c-44f0-b471-156ed5829b3e
# ╠═f87e71e4-be18-4c2e-8a9e-f20e731570d9
# ╠═73399877-352c-411c-a3d3-77b6a6d21cb6
# ╟─1bd2a462-2f4a-4cdb-b1e3-17ed02454839
# ╟─a4fa5ecb-6a82-43db-8fef-8a106684751e
# ╟─dc83fca3-35b9-4f7e-af0b-004490671439
# ╠═7056eb21-ba88-47c2-a053-4913d8f0f013
# ╠═e5def323-17a6-441b-bf5c-1241f46e3436
# ╠═7e0bd601-9a95-47ea-9ba4-0a8d297d2acc
# ╟─481fa23f-698c-4bd3-addf-057167fadd1c
# ╠═d095d44c-c04a-43fa-985a-c358db7280d7
# ╟─e3c50826-b007-4b1b-9283-41c4862c5d0f
# ╠═ba8d0e88-78fc-4587-99af-08a2ef83e91c
# ╠═f67baa05-26d3-4639-b8ff-b801f2ddd47f
# ╠═fed755ff-03b6-42bc-956a-0f950025553b
# ╠═c0745d5d-56a1-40ff-8635-878d0a45ae65
# ╟─d02064ad-695a-43f0-bc2e-251f216c15b4
# ╠═c4a516b3-dec7-4ad2-b146-baed0bb95e67
# ╠═4c226f67-e5ad-453b-8e4e-99a5aafbdd7c
# ╠═6ab4b77a-ead0-4d5c-be18-865223cb202c
# ╠═984df1d6-340e-4069-a55c-8d11899ab490
# ╠═e5897d2d-fcf4-4895-8e5e-d52c59d6f99f

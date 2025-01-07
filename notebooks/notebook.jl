### A Pluto.jl notebook ###
# v0.20.3

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

* **Hamiltonian system**s (mechanics, and also classical electromagnetism)
    * **energy function** ("Hamiltonian")
    * **symplectic structure**
     (or more general Poisson-/presymplectic-/Dirac structures)
* Thermodynamic modeling (here focus on CIT/LIT)
    * **first and second law**
    * **reversible-irreversible splitting** of dynamics
        * reversible dynamics don't dissipate (no entropy production)
        * irreversible dynamics are energy conserving
    * Onsager symmetry
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

# ╔═╡ 67eac152-f37b-4088-b060-6b4cdb87b1dc
md"""
## Discussion about bond graphs

* subsystems are primitive elements
  * we could allow **arbitrarily complex subsystems**!
* composed system (network of elements) is itself closed
  * we could **allow bond graphs to be open** (**outer box**/interface)
* composition should ...
  * **exist** when interfaces match
  * be **unique**, given no further data than the bond graphs, which are to be composed
  * be **associative** (unique flattened hierachy of bond graphs)
"""

# ╔═╡ 5c604120-4b49-4b4c-9d04-0eaf2405ebe8
md"""
## Discussion about port-Hamiltonian systems

* port-Hamiltonian systems compose
* concept of subsystems is not explicit
  * similar to (3 + 4 ⤳ 7; 2 + 5 ⤳ 7)
    * 7 does not remember it is a 3 + 4
* we could make explicit the concepts of
  * subsystems and their ports (interface)
* a model/system is a hierarchy of port-Hamiltonian systems
  * systems have subsystems, which may have further subsystems ...
"""

# ╔═╡ 00d618cf-a8b2-4a14-b944-01a3fb9724ec
md"""
## Discussion summary

* bond graphs are reticulated presentations of a system, which are not composable as such
* port-Hamiltonian systems are composable, but composite systems are not defined using a graphical syntax similar to bond graphs
"""

# ╔═╡ 663b6e88-18ff-4ff7-a333-e6807ef49e67
md"""
## Approach behind `EPHS.jl`

* formalize modularity and hierarchical nesting of systems through composable, graphical syntax (applied category theory)

* syntax: composable, simpler version of open bond graphs
* thermodynamic modeling
  * first and second law, reversible-irreversible splitting, ...
  * syntax is energy/exergy flow diagram (as used in engineering thermodynamics)
"""

# ╔═╡ 1a3f9083-6169-4327-84f9-6d62332e9aba
md"""
## `Dtry`, the monadic data structure behind `EPHS.jl`

**A directory contains values associated to a hierarchically-defined system**

Example: (real-valued) initial conditions
"""

# ╔═╡ 49d533ca-3ced-4814-983e-3c7c69adfe31
ics = Dtry(
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
ics.osc # access subdirectory named `osc`

# ╔═╡ 1233a4cf-4871-4852-a332-418dff69e405
ics.tc.s

# ╔═╡ 3164fe5b-cd32-4f3e-bb60-9cc0b5d73ecb
ics.tc.s[]

# ╔═╡ aa6e9e66-00eb-46ee-8607-f80687ce7ff4
ics[■.osc.pe.q]

# ╔═╡ c4f2a81e-684e-4b56-a0b4-6ed112a6da40
md"""
### Monad structure

- `Dtry : T -> Dtry{T}`
- `flatten : Dtry{{Dtry{T}}} -> Dtry{T}`
"""

# ╔═╡ d4d14845-8c6c-4c2b-9f3b-fe893c275d17
Dtry("hello world") # monad unit

# ╔═╡ d71a7ecb-e8f6-4f7b-96ec-4798cce74c23
Dtry(
  :oszillator => Dtry(ics.osc), # directory as value!
  :thermische_kapazitaet => Dtry(ics.tc)
) |> flatten # monad multiplication

# ╔═╡ 1110a995-96ed-4d27-a17e-a07462451cd6
md"""
## Syntax is a `Dtry`-multicategory

* objects: system interfaces (directories of ports)
* morphisms: interconnection patterns
* can combine systems/interfaces/patterns in parallel via directories
* composition: hierarchical nesting of systems/patterns
"""

# ╔═╡ 63dd09e4-da2f-40f8-91ea-6986ef016055
md"""
A `Dtry`-multicategory is essentially a human-friendly strictification of a symmetric monoidal category


Rather than using a binary monoidal product (i.e. a bifunctor required to satisfy coherence diagrams) to combine objects/morphisms in parallel,
`Dtry`-multicategory uses human-friendly names to address parts of combined objects/morphisms.

Examples:
* combination of multiple subsystems of an interconnection pattern
* combination of multiple ports and parameters of a system
"""

# ╔═╡ 2f61d0a9-eb87-42c3-8b4b-98ff28861d53
pattern_osc = Pattern(
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

# ╔═╡ 58418029-d0bc-42e0-b818-67356268f662
md"""
Interconnection pattern of mechanical oscillator:
* pe - potential energy (storage)
* ke - kinetic energy (storage)
* pkc - potential-kinetic coupling (canonical symplectic structure)
"""

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

# ╔═╡ 3f0e20ac-fa7a-4af8-a65f-b0e27e4ee737
@assert interface(pattern_damped_osc, ■.osc) == interface(pattern_osc)

# ╔═╡ 1bd2a462-2f4a-4cdb-b1e3-17ed02454839
md"""
#### Let's add semantics
"""

# ╔═╡ de5e1060-1960-4473-b1d1-b613637ceca2
md"""
A system is either primitive or composed of other systems
"""

# ╔═╡ 06dbd3ee-e48a-40f5-ac70-9c88ef030a8e
subtypes(AbstractSystem)

# ╔═╡ dc83fca3-35b9-4f7e-af0b-004490671439
md"""
There are three types of primitive systems (called "components")
"""

# ╔═╡ 191694be-923a-4160-ac3e-6f0bc4912814
subtypes(Component)

# ╔═╡ 481fa23f-698c-4bd3-addf-057167fadd1c
md"""
A composite system is given by an interconnection pattern,
where each inner box is filled by a system!

- each subsystem implies a relation
- pattern implies a relation
- composing these relations gives the relation implied by the composite system
"""

# ╔═╡ bd8d67cf-39a0-4596-b00e-8fc7465397d8
md"""
So, let's define the relevant components:
"""

# ╔═╡ 89330912-a6b4-4a92-8963-9d6e169e6acf
pe = let
  k = Par(:k, 1.5)
  q = XVar(:q)
  E = Const(1/2) * k * q^Const(2)
  StorageComponent(
    Dtry(
      :q => Dtry(displacement)
    ),
    E
  )
end

# ╔═╡ c50a90fc-50b1-4977-93cb-cffb47c0986e
ke = let
  m = Par(:m, 1.)
  p = XVar(:p)
  E = Const(1/2) * p^Const(2) / m
  StorageComponent(
    Dtry(
      :p => Dtry(momentum)
    ),
    E
  )
end

# ╔═╡ 8b3e79a4-fb59-46cb-b113-8e69249bb7a7
pkc = ReversibleComponent(
  Dtry(
    :q => Dtry(ReversiblePort(FlowPort(displacement, -EVar(:p)))),
    :p => Dtry(ReversiblePort(FlowPort(momentum, EVar(:q))))
  )
)

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
        pe, # storage component for potential energy
        Position(1,1)
      ),
    ),
    :ke => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        ke, # storage component for kinetic energy
        Position(1,5)
      ),
    ),
    :pkc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
          :p => Dtry(InnerPort(■.p))
        ),
        pkc, # Reversible component for potential-kinetic coupling
        Position(1,3)
      ),
    ),
  )
)

# ╔═╡ ba8d0e88-78fc-4587-99af-08a2ef83e91c
assemble(osc) |> equations |> print

# ╔═╡ eb02ca60-5cf6-4179-8770-a8f3cf255d64
tc = let
  c₁ = Par(:c₁, 1.0)
  c₂ = Par(:c₂, 2.0)
  s = XVar(:s)
  E = c₁ * exp(s / c₂)
  StorageComponent(
    Dtry(
      :s => Dtry(entropy)
    ),
    E
  )
end

# ╔═╡ f84a78b0-fc6c-424e-a5f8-edce7e06b7c2
mf = let
  d = Par(:d, 0.02)
  p₊e = EVar(:p)
  s₊e = EVar(:s)
  p₊f = d * p₊e
  s₊f = -((d * p₊e * p₊e) / (θ₀ + s₊e))
  IrreversibleComponent(
    Dtry(
      :p => Dtry(IrreversiblePort(momentum, p₊f)),
      :s => Dtry(IrreversiblePort(entropy, s₊f))
    )
  )
end

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
        mf, # irreversible component (mechanical friction)
        Position(1,3)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        tc, # storage component (thermal capacity)
        Position(1,5)
      ),
    ),
  )
)

# ╔═╡ c0745d5d-56a1-40ff-8635-878d0a45ae65
assemble(osc_damped)

# ╔═╡ d02064ad-695a-43f0-bc2e-251f216c15b4
md"""
#### Now, let's run a simulation

First, we set an initial condition for the hierarchically defined system:
"""

# ╔═╡ c4a516b3-dec7-4ad2-b146-baed0bb95e67
sim = simulate(osc_damped, midpoint_rule, ics, 0.01, 20);

# ╔═╡ d7cee76d-caf0-40ec-ba9e-cad4566bb896
f = osc_damped |> assemble |> midpoint_rule

# ╔═╡ 984df1d6-340e-4069-a55c-8d11899ab490
let
q = XVar(DtryPath(:osc, :pe), DtryPath(:q))
p = XVar(DtryPath(:osc, :ke), DtryPath(:p))
plot_evolution(sim, q, p)
end

# ╔═╡ e5897d2d-fcf4-4895-8e5e-d52c59d6f99f
let
s = XVar(DtryPath(:tc), DtryPath(:s))
plot_evolution(sim, s)
end

# ╔═╡ f46afc98-c50d-4432-9ef7-8efd68f86353
md"""
#### DAE example
"""

# ╔═╡ db5a47d3-96f2-4004-8826-2fa6d3471c95
hc = let
  λ = CVar(:λ)
  ReversibleComponent(
    Dtry(
      :q => Dtry(ReversiblePort(FlowPort(displacement, λ))),
      :q₂ => Dtry(ReversiblePort(FlowPort(displacement, -λ))),
      :λ => Dtry(ReversiblePort(Constraint(-EVar(:q) + EVar(:q₂))))
    )
  )
end

# ╔═╡ 974cc4ba-bdcb-4e67-83af-aa63e42a91b1
osc_constraint = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(displacement, Position(1, 2))),
    :p => Dtry(Junction(momentum, Position(1, 4))),
    :q₂ => Dtry(Junction(displacement, Position(3, 2))),
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
    :hc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
          :q₂ => Dtry(InnerPort(■.q₂)),
        ),
        hc,
        Position(2, 2)
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
  )
)

# ╔═╡ 494185ac-87c9-40fb-bde4-9d208ba73fb3
assemble(osc_constraint)

# ╔═╡ 649578a2-ed83-4b81-9d23-53012972026b
md"""
# Possible next steps

- Show that the language framework and its implementation scales
"""

# ╔═╡ Cell order:
# ╟─617a56bb-2793-48ae-b845-b802fe8d3454
# ╟─2001e3e6-3d5a-40ee-964f-2fe1fbff3ebe
# ╟─88752a0c-de2e-11ef-1572-c10479e38922
# ╟─0296f687-7e3f-471e-b431-a63330976154
# ╟─08f633bc-0e00-4fb6-9464-b48db005c7e9
# ╟─67eac152-f37b-4088-b060-6b4cdb87b1dc
# ╟─5c604120-4b49-4b4c-9d04-0eaf2405ebe8
# ╟─00d618cf-a8b2-4a14-b944-01a3fb9724ec
# ╟─663b6e88-18ff-4ff7-a333-e6807ef49e67
# ╟─1a3f9083-6169-4327-84f9-6d62332e9aba
# ╠═49d533ca-3ced-4814-983e-3c7c69adfe31
# ╠═0ebf6384-77f4-4c49-8faf-17b8549f5ad0
# ╠═1233a4cf-4871-4852-a332-418dff69e405
# ╠═3164fe5b-cd32-4f3e-bb60-9cc0b5d73ecb
# ╠═aa6e9e66-00eb-46ee-8607-f80687ce7ff4
# ╟─c4f2a81e-684e-4b56-a0b4-6ed112a6da40
# ╠═d4d14845-8c6c-4c2b-9f3b-fe893c275d17
# ╠═d71a7ecb-e8f6-4f7b-96ec-4798cce74c23
# ╟─1110a995-96ed-4d27-a17e-a07462451cd6
# ╟─63dd09e4-da2f-40f8-91ea-6986ef016055
# ╠═2f61d0a9-eb87-42c3-8b4b-98ff28861d53
# ╟─58418029-d0bc-42e0-b818-67356268f662
# ╠═20cba0e2-dd7f-457d-b612-b45ecce76657
# ╟─d605e9e6-5e5c-44f0-b471-156ed5829b3e
# ╠═f87e71e4-be18-4c2e-8a9e-f20e731570d9
# ╠═3f0e20ac-fa7a-4af8-a65f-b0e27e4ee737
# ╟─1bd2a462-2f4a-4cdb-b1e3-17ed02454839
# ╟─de5e1060-1960-4473-b1d1-b613637ceca2
# ╠═06dbd3ee-e48a-40f5-ac70-9c88ef030a8e
# ╟─dc83fca3-35b9-4f7e-af0b-004490671439
# ╠═191694be-923a-4160-ac3e-6f0bc4912814
# ╟─481fa23f-698c-4bd3-addf-057167fadd1c
# ╟─bd8d67cf-39a0-4596-b00e-8fc7465397d8
# ╠═89330912-a6b4-4a92-8963-9d6e169e6acf
# ╟─c50a90fc-50b1-4977-93cb-cffb47c0986e
# ╟─8b3e79a4-fb59-46cb-b113-8e69249bb7a7
# ╠═e3c50826-b007-4b1b-9283-41c4862c5d0f
# ╠═ba8d0e88-78fc-4587-99af-08a2ef83e91c
# ╟─eb02ca60-5cf6-4179-8770-a8f3cf255d64
# ╟─f84a78b0-fc6c-424e-a5f8-edce7e06b7c2
# ╟─f67baa05-26d3-4639-b8ff-b801f2ddd47f
# ╠═c0745d5d-56a1-40ff-8635-878d0a45ae65
# ╟─d02064ad-695a-43f0-bc2e-251f216c15b4
# ╠═c4a516b3-dec7-4ad2-b146-baed0bb95e67
# ╠═d7cee76d-caf0-40ec-ba9e-cad4566bb896
# ╠═984df1d6-340e-4069-a55c-8d11899ab490
# ╠═e5897d2d-fcf4-4895-8e5e-d52c59d6f99f
# ╟─f46afc98-c50d-4432-9ef7-8efd68f86353
# ╟─db5a47d3-96f2-4004-8826-2fa6d3471c95
# ╟─974cc4ba-bdcb-4e67-83af-aa63e42a91b1
# ╠═494185ac-87c9-40fb-bde4-9d208ba73fb3
# ╟─649578a2-ed83-4b81-9d23-53012972026b

"""
Library of pre-defined reverisble components.
"""
module ReversibleComponentLibrary

using ...Directories
using ...SymbolicExpressions
using ...AbstractSystems
using ...Components


export pkc
export emc
export mkc
export mechanical_lever
export two_springs_series_connection, two_masses_rigid_connection
export hkc


@doc raw"""
Potential-kinetic coupling:
Reversible coupling of
a potential energy domain at port ``\mathtt{q}`` (displacement) and
a kinetic enregy domain at port ``\mathtt{p}`` (momentum).
The Dirac structure is given by
```math
\begin{bmatrix}
  \mathtt{q.f} \\
  \mathtt{p.f}
\end{bmatrix}
\: = \:
\begin{bmatrix}
  0 & -1 \\
  +1 & 0
\end{bmatrix}
\,
\begin{bmatrix}
  \mathtt{q.e} \\
  \mathtt{p.e}
\end{bmatrix}
\,.
```
"""
const pkc = ReversibleComponent(
  Dtry(
    :q => Dtry(ReversiblePort(FlowPort(displacement, -EVar(:p)))),
    :p => Dtry(ReversiblePort(FlowPort(momentum, EVar(:q))))
  )
)


@doc raw"""
Electromagnetic coupling:
Reversible coupling of
an electric energy domain at port ``\mathtt{q}`` (charge) and
a magnetic enregy domain at port ``\mathtt{b}`` (magnetic flux).
The Dirac structure is given by
```math
\begin{bmatrix}
  \mathtt{q.f} \\
  \mathtt{b.f}
\end{bmatrix}
\: = \:
\begin{bmatrix}
  0 & +1 \\
  -1 & 0
\end{bmatrix}
\,
\begin{bmatrix}
  \mathtt{q.e} \\
  \mathtt{b.e}
\end{bmatrix}
\,.
```
"""
const emc = ReversibleComponent(
  Dtry(
    :q => Dtry(ReversiblePort(FlowPort(charge, EVar(:b)))),
    :b => Dtry(ReversiblePort(FlowPort(magnetic_flux, -EVar(:q))))
  )
)


@doc raw"""
Magnetic-kinetic coupling:
Reversible coupling of
of a magnetic energy domain at port ``\mathtt{b}`` (magnetic flux) and
a kinetic energy domain at port ``\mathtt{p}`` (angular momentum)
based on the Lorentz force.
The strength of the coupling is proportional to
the magnetic flux at the state port ``\mathtt{b_s}``.
The Dirac structure is given by
```math
\begin{bmatrix}
  \mathtt{b.f} \\
  \mathtt{p.f}
\end{bmatrix}
\: = \:
\begin{bmatrix}
  0 & +\mathtt{b_s.x} \\
  -\mathtt{b_s.x} & 0
\end{bmatrix}
\,
\begin{bmatrix}
  \mathtt{b.e} \\
  \mathtt{p.e}
\end{bmatrix}
\,.
```
"""
const mkc = let
  bₛ₊x = XVar(:bₛ)
  b₊e = EVar(:b)
  p₊e = EVar(:p)
  b₊f = bₛ₊x * p₊e
  p₊f = -(bₛ₊x * b₊e)
  ReversibleComponent(
    Dtry(
      :b => Dtry(ReversiblePort(FlowPort(magnetic_flux, b₊f))),
      :p => Dtry(ReversiblePort(FlowPort(angular_momentum, p₊f))),
      :bₛ => Dtry(ReversiblePort(StatePort(magnetic_flux)))
    )
  )
end


@doc raw"""
    mechanical_lever(; r::Float64) -> ReversibleComponent

Create an ideal mechanical lever
connecting two potential energy domains
via the leverage ratio ``r``.
The Dirac structure is given by
```math
\begin{bmatrix}
  \mathtt{q_1.f} \\
  \mathtt{q_2.e}
\end{bmatrix}
\: = \:
\begin{bmatrix}
  0 & -r \\
  +r & 0
\end{bmatrix}
\,
\begin{bmatrix}
  \mathtt{q_1.e} \\
  \mathtt{q_2.f}
\end{bmatrix}
\,.
```
"""
mechanical_lever(; r::Float64) =
  let
    r = Par(:r, r)
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


@doc raw"""
Dirac structure for connecting two springs in series:
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
The constraint variable ``\lambda`` distributes
the rates of change of the displacement variables ``\mathtt{q.f}`` and ``\mathtt{q_2.f}``
such that the forces ``\mathtt{q.e}`` and ``\mathtt{q_2.e}`` are equal.
"""
const two_springs_series_connection =
  let
    λ = CVar(:λ)
    ReversibleComponent(
      Dtry(
        :q => Dtry(ReversiblePort(FlowPort(displacement, λ))),
        :q₂ => Dtry(ReversiblePort(FlowPort(displacement, -λ))),
        :λ => Dtry(ReversiblePort(Constraint(-EVar(:q) + EVar(:q₂))))
      )
    )
  end


@doc raw"""
Dirac structure for a rigid connection of two masses:
```math
\begin{bmatrix}
  \mathtt{p.f} \\
  \mathtt{p_2.f} \\
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
  \mathtt{p.e} \\
  \mathtt{p_2.e} \\
  \lambda
\end{bmatrix}
```
The constraint variable ``\lambda`` distributes
the rates of change of the momentum variables ``\mathtt{p.f}`` and ``\mathtt{p_2.f}``
such that the velocities ``\mathtt{p.e}`` and ``\mathtt{p_2.e}`` are equal.

"""
const two_masses_rigid_connection =
  let
    λ = CVar(:λ)
    ReversibleComponent(
      Dtry(
        :p => Dtry(ReversiblePort(FlowPort(momentum, λ))),
        :p₂ => Dtry(ReversiblePort(FlowPort(momentum, -λ))),
        :λ => Dtry(ReversiblePort(Constraint(-EVar(:p) + EVar(:p₂))))
      )
    )
  end


@doc raw"""
    hkc(; a::Float64) -> ReversibleComponent

Hydraulic-kinetic coupling:
Create a reversible coupling between
the two hydraulic energy domains on either side of a piston
(ports ``\mathtt{v_1}`` and ``\mathtt{v_2}``)
and the kinetic energy domain of the piston itself
(port ``\mathtt{p}``).
The Dirac structure is given by
```math
\begin{bmatrix}
  \mathtt{p.f} \\
  \mathtt{v_1.f} \\
  \mathtt{v_2.f}
\end{bmatrix}
\: = \:
\begin{bmatrix}
  0  & +a & -a \\
  -a &  0 &  0 \\
  +a &  0 &  0 \\
\end{bmatrix}
\,
\begin{bmatrix}
  \mathtt{p.e} \\
  \mathtt{v_1.e} \\
  \mathtt{v_2.e}
\end{bmatrix}
\,,
```
where
the parameter ``a`` is the cross-sectional area of the piston.
"""
hkc(; a::Float64) =
  let
    a = Par(:a, a)
    v₁₊e = EVar(:v₁)
    v₂₊e = EVar(:v₂)
    p₊e = EVar(:p)
    v₁₊f = -(a * p₊e)
    v₂₊f = a * p₊e
    p₊f = a * (v₁₊e - v₂₊e)
    ReversibleComponent(
      Dtry(
        :v₁ => Dtry(ReversiblePort(FlowPort(volume, v₁₊f))),
        :v₂ => Dtry(ReversiblePort(FlowPort(volume, v₂₊f))),
        :p => Dtry(ReversiblePort(FlowPort(momentum, p₊f))),
      ))
  end

end

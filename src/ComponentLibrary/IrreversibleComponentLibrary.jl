"""
Library of pre-defined irreverisble components.
"""
module IrreversibleComponentLibrary

using ...Directories
using ...SymbolicExpressions
using ...AbstractSystems
using ...Components


export linear_friction, rotational_friction
export magnetic_resistor
export heat_transfer


@doc raw"""
    linear_friction(d::Float64) -> IrreversibleComponent

Create a linear model of mechanical friction
with default friction parameter ``d``.
The Onsager structure is given by
```math
\begin{bmatrix}
  \mathtt{p.f} \\
  \mathtt{s.f}
\end{bmatrix}
\: = \:
\frac{1}{\theta_0} \, d \,
\begin{bmatrix}
  \theta & -\upsilon \\
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
\,,
```
where
``\upsilon = \mathtt{p.e}``
is the velocity
associated with kinetic energy domain at port ``\mathtt{p}`` (momentum)
and
``\theta = \theta_0 + \mathtt{s.e}``
is the absolute temperature
at which kinetic energy is dissipated
into the thermal energy domain at port ``\mathtt{s}`` (entropy).
"""
linear_friction(d::Float64) =
  let
    d = Par(:d, d)
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


@doc raw"""
    rotational_friction(d::Float64) -> IrreversibleComponent

Create a linear model of rotational friction
with default friction parameter ``d``.
The Onsager structure is given by
```math
\begin{bmatrix}
  \mathtt{p.f} \\
  \mathtt{s.f}
\end{bmatrix}
\: = \:
\frac{1}{\theta_0} \, d \,
\begin{bmatrix}
  \theta & \upsilon \\
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
\,,
```
where
``\upsilon = \mathtt{p.e}``
is the angular velocity
associated with kinetic energy domain at port ``\mathtt{p}`` (momentum)
and
``\theta = \theta_0 + \mathtt{s.e}``
is the absolute temperature
at which kinetic energy is dissipated
into the thermal energy domain at port ``\mathtt{s}`` (entropy).
"""
rotational_friction(d::Float64) =
  let
    d = Par(:d, d)
    p₊e = EVar(:p)
    s₊e = EVar(:s)
    p₊f = d * p₊e
    s₊f = -((d * p₊e * p₊e) / (θ₀ + s₊e))
    IrreversibleComponent(
      Dtry(
        :p => Dtry(IrreversiblePort(angular_momentum, p₊f)),
        :s => Dtry(IrreversiblePort(entropy, s₊f))
      )
    )
  end


@doc raw"""
    magnetic_resistor(r::Float64) -> IrreversibleComponent

Create a model of a linear resistor
with default resistance parameter ``r``.
The Onsager structure is given by
```math
\begin{bmatrix}
  \mathtt{b.f} \\
  \mathtt{s.f}
\end{bmatrix}
\: = \:
\frac{1}{\theta_0} \, r \,
\begin{bmatrix}
  \theta & i \\
  -i & \frac{\upsilon^2}{\theta}
\end{bmatrix}
\,
\begin{bmatrix}
  \mathtt{b.e} \\
  \mathtt{s.e}
\end{bmatrix}
\: = \:
\begin{bmatrix}
  r \, i \\
  -\frac{r \, i^2}{\theta}
\end{bmatrix}
\,,
```
where
``i = \mathtt{b.e}``
is the current
associated with magnetic energy domain at port ``\mathtt{b}`` (magnetic flux)
and
``\theta = \theta_0 + \mathtt{s.e}``
is the absolute temperature
at which magnetic energy is dissipated
into the thermal energy domain at port ``\mathtt{s}`` (entropy).
"""
magnetic_resistor(r::Float64) =
  let
    r = Par(:r, r)
    b₊e = EVar(:b)
    s₊e = EVar(:s)
    b₊f = r * b₊e
    s₊f = -((r * b₊e * b₊e) / (θ₀ + s₊e))
    IrreversibleComponent(
      Dtry(
        :b => Dtry(IrreversiblePort(magnetic_flux, b₊f)),
        :s => Dtry(IrreversiblePort(entropy, s₊f))
      )
    )
  end


@doc raw"""
    heat_transfer(α::Float64) -> IrreversibleComponent

Create a linear model of heat transfer
with default heat transfer parameter ``\alpha``.
The Onsager sturcutre is given by
```math
\begin{bmatrix}
  \mathtt{s₁.f} \\
  \mathtt{s₂.f}
\end{bmatrix}
\: = \:
\frac{1}{\theta_{0}}
\, \alpha \,
\begin{bmatrix}
  \frac{\theta_{2}}{\theta_{1}} & -1 \\
  -1 & \frac{\theta_{1}}{\theta_{2}}
\end{bmatrix}
\,
\begin{bmatrix}
  \mathtt{s₁.e} \\
  \mathtt{s₂.e}
\end{bmatrix}
\: = \:
\begin{bmatrix}
  -\frac{\alpha \, (\theta_2 - \theta_1)}{\theta_1} \\
  -\frac{\alpha \, (\theta_1 - \theta_2)}{\theta_2}
\end{bmatrix}
\,,
```
where
``\theta_{1} = \theta_{0} + \mathtt{s₁.e}``
and
``\theta_{2} = \theta_{0} + \mathtt{s₂.e}``
represent the absolute temperature
of the two thermal energy domains.
"""
heat_transfer(α::Float64) =
  let
    α = Par(:α, α)
    s₁₊e = EVar(:s₁)
    s₂₊e = EVar(:s₂)
    θ₁ = θ₀ + s₁₊e
    θ₂ = θ₀ + s₂₊e
    s₁₊f = -(α * (θ₂ - θ₁) / θ₁)
    s₂₊f = -(α * (θ₁ - θ₂) / θ₂)
    IrreversibleComponent(
      Dtry(
        :s₁ => Dtry(IrreversiblePort(entropy, s₁₊f)),
        :s₂ => Dtry(IrreversiblePort(entropy, s₂₊f)),
      )
    )
  end

end

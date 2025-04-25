"""
Library of pre-defined storage components.
"""
module StorageComponentLibrary

using ...Directories
using ...SymbolicExpressions
using ...AbstractSystems
using ...Components


export hookean_spring
export point_mass, angular_mass
export linear_inductor
export thermal_capacity, ideal_gas


@doc raw"""
    hookean_spring(k::Float64) -> StorageComponent

Create a Hookean spring
with default stiffness parameter ``k``.
The energy function is given by
``E(q) = \frac{1}{2} \, k \, q^2``,
where
``q`` is the displacement variable.
"""
hookean_spring(k::Float64) =
  let
    k = Par(:k, k)
    q = XVar(:q)
    E = Const(1 / 2) * k * q^Const(2)
    StorageComponent(
      Dtry(
        :q => Dtry(displacement)
      ),
      E
    )
  end


@doc raw"""
    point_mass(m::Float64) -> StorageComponent

Create a point mass
with default mass parameter ``m``.
The energy function is given by
``E(p) = \frac{1}{2 \, m} \, p^2``,
where
``p`` is the momentum variable.
"""
point_mass(m::Float64) =
  let
    m = Par(:m, m)
    p = XVar(:p)
    E = Const(1 / 2) * p^Const(2) / m
    StorageComponent(
      Dtry(
        :p => Dtry(momentum)
      ),
      E
    )
  end


@doc raw"""
    angular_mass(m::Float64) -> StorageComponent

Create an angular mass
with default angular mass parameter ``m``.
The energy function is given by
``E(p) = \frac{1}{2 \, m} \, p^2``,
where
``p`` is the angular momentum variable.
"""
angular_mass(m::Float64) =
  let
    m = Par(:m, m)
    p = XVar(:p)
    E = Const(1 / 2) * p^Const(2) / m
    StorageComponent(
      Dtry(
        :p => Dtry(angular_momentum)
      ),
      E
    )
  end


@doc raw"""
    linear_inductor(l::Float64) -> StorageComponent

Create a linear inductor
with default inductivity parameter ``l``.
The energy function is given by
``E(b) = \frac{1}{2 \, l} \, b^2``,
where
``b`` is the magnetic flux variable.
"""
linear_inductor(l::Float64) =
  let
    l = Par(:l, l)
    b = XVar(:b)
    E = Const(0.5) * b^Const(2) / l
    StorageComponent(
      Dtry(
        :b => Dtry(magnetic_flux)
      ),
      E
    )
  end


@doc raw"""
    thermal_capacity(c₁::Float64, c₂::Float64) -> StorageComponent

Create a model of a thermal capacity.
The energy function is
``E(s) = c_1 \, \exp(\frac{s}{c_2})``,
where
``s`` is the entropy variable and
``c_1`` and ``c_2`` are constitutive parameters.
"""
thermal_capacity(c₁::Float64, c₂::Float64) =
  let
    c₁ = Par(:c₁, c₁)
    c₂ = Par(:c₂, c₂)
    s = XVar(:s)
    E = c₁ * exp(s / c₂)
    StorageComponent(
      Dtry(
        :s => Dtry(entropy)
      ),
      E
    )
  end


@doc raw"""
    ideal_gas(c₁::Float64, c₂::Float64, v₀::Float64, c::Float64) -> StorageComponent

Create an ideal gas model.
The energy function is given by
``E(s, \, v) = c_1 \, \exp(\frac{s}{c_2}) \, {(\frac{v_0}{v})}^{\frac{1}{c}}``,
where
``s`` is the entropy variable,
``v`` is the volume variable,
and
``c_1``, ``c_2``, ``v_0`` and ``c`` are constitutive parameters.
"""
ideal_gas(c₁::Float64, c₂::Float64, v₀::Float64, c::Float64) =
  let
    c₁ = Par(:c₁, c₁)
    c₂ = Par(:c₂, c₂)
    v₀ = Par(:v₀, v₀)
    c = Par(:c, c)
    s = XVar(:s)
    v = XVar(:v)
    E = c₁ * exp(s / c₂) * (v₀ / v)^(Const(1) / c)
    StorageComponent(
      Dtry(
        :s => Dtry(entropy),
        :v => Dtry(volume),
      ),
      E
    )
  end

end

# Pre-defined quantities
# Quantity(quantity::Symbol, space::Symbol, iseven::Bool)

"[`Quantity`](@ref) representing a real-valued displacement"
const displacement = Quantity(:displacement, :ℝ, true)


"[`Quantity`](@ref) representing a real-valued linear momentum"
const momentum = Quantity(:momentum, :ℝ, false)


"[`Quantity`](@ref) representing a real-valued angular momentum"
const angular_momentum = Quantity(:angular_momentum, :ℝ, false)


"[`Quantity`](@ref) representing an entropy"
const entropy = Quantity(:entropy, :ℝ, true)


"[`Quantity`](@ref) representing an electric charge"
const charge = Quantity(:charge, :ℝ, true)


"[`Quantity`](@ref) representing a magnetic flux"
const magnetic_flux = Quantity(:magnetic_flux, :ℝ, false)


"[`Quantity`](@ref) representing a volume"
const volume = Quantity(:volume, :ℝ, true)

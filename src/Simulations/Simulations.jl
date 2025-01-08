module Simulations

using ForwardDiff: jacobian
using LinearAlgebra: norm
using RuntimeGeneratedFunctions
using StaticArrays

using ..AbstractSystems
using ..CompositeSystems
using ..SymbolicExpressions


export nlsolve
export midpoint_rule
export simulate
export Simulation


RuntimeGeneratedFunctions.init(@__MODULE__)


include("nlsolve.jl")


ast0(pvar::PortVar) = Symbol(replace(string(pvar), '.' => '₊') * "₀")
ast1(pvar::PortVar) = Symbol(replace(string(pvar), '.' => '₊') * "₁")


include("midpoint.jl")


function simulate(update::Function, x₀::T, h::Float64, tₑ::Float64) where {T<:SVector}
  n = trunc(Int, tₑ / h)
  xs = Vector{T}(undef, n)
  xs[1] = x₀
  for i in 1:n-1
    xs[i+1] = update(xs[i], h)
  end
  xs
end


struct Simulation
  sys::CompositeSystem
  method::Function
  h::Float64
  xs::Vector
end


function simulate(sys::CompositeSystem, method::Function, x₀::AbstractVector, h::Real, tₑ::Real)
  update = method(sys)
  ic = x₀ isa SVector ? x₀ : SVector{length(x₀),Float64}(x₀)
  xs = simulate(update, ic, convert(Float64, h), convert(Float64, tₑ))
  Simulation(sys, method, h, xs)
end


end

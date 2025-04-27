"""
The `Simulations` module provides
the [`simulate`](@ref) function
to compute the time evolution of composite systems,
starting from an initial condition.
As an argument, the function takes a numerical method,
such as [`midpoint_rule`](@ref).
Based on the `DAESystem` obtained from the `CompositeSystem`,
this method generates Julia code,
which is then called in a time-stepping loop.
Further, the module provides functionality for
post-processing and plotting of the [`SimulationResult`](@ref),
see [`evolution`](@ref) and [`plot_evolution`](@ref).
"""
module Simulations

using ForwardDiff: jacobian
using LinearAlgebra: norm
using RuntimeGeneratedFunctions
using StaticArrays

using ..Directories
using ..AbstractSystems
using ..Components: CVar
using ..CompositeSystems
using ..SymbolicExpressions


export nlsolve
export midpoint_rule
export simulate
export SimulationResult
export timegrid
export evolution
export plot_evolution
export plot_convergence


# "magic" needed to generate functions at runtime without world-age issues
RuntimeGeneratedFunctions.init(@__MODULE__)


# solver for systems of nonlinear equations (Newton–Raphson method)
include("nlsolve.jl")


# discrete-time variables
SymbolicExpressions.ast(pvar::Union{PortVar,CVar}, postfix::String) =
  Symbol(replace(string(pvar), '.' => '₊'), postfix)


# implicit midpoint rule
include("midpoint.jl")


# time stepping loop which uses
# `x₁ = update(x₀, h)` in every step
function simulate(update::Function, x₀::T, h::Float64, tₑ::Float64) where {T<:SVector}
  n = trunc(Int, tₑ / h)
  xs = Vector{T}(undef, n)
  xs[1] = x₀
  for i in 1:n-1
    xs[i+1] = update(xs[i], h)
  end
  xs
end


"""
    SimulationResult(
        sys::CompositeSystem,
        dae::DAESystem,
        method::Function,
        h::Float64,
        xs::Vector
    )

Data structure returned by [`simulate`](@ref).

# Fields
- `sys`: [`CompositeSystem`](@ref)
- `dae`: the resulting `DAESystem` obtaind by `assemble(sys)`
- `method`: the numerical method (e.g. `midpoint_rule`)
- `h`: time step size
- `xs`: simulation result (`xs[1]` is initial condition)
"""
struct SimulationResult
  sys::CompositeSystem
  dae::DAESystem
  method::Function
  h::Float64
  xs::Vector
end


"""
    simulate(
      sys::CompositeSystem,
      method::Function,
      ic::Union{Vector, AbstractDtry{Float64}},
      h::Real,
      tₑ::Real;
      ps::AbstractDtry{Float64}=Dtry{Float64}()
    ) -> SimulationResult

Simulate the evolution of an isolated `CompositeSystem`.

# Arguments
- `sys`: the isolated system
- `method`: the numerical method used for simulation
- `ic`: directory of initial conditions for the state variables of all storage components
- `h`: time step size
- `tₑ`: final time (duration of simulation)
- `ps`: directory of parameters to update before simulation (optional keyword argument)

Returns a [`SimulationResult`](@ref).
"""
function simulate(
  sys::CompositeSystem,
  method::Function,
  ic::AbstractDtry{Float64},
  h::Real,
  tₑ::Real;
  ps::AbstractDtry{Float64}=Dtry{Float64}()
)
  dae = assemble(sys)
  dae = update_parameters(dae, ps)
  update = method(dae)
  xs = simulate(update, initial_value(ic, dae), convert(Float64, h), convert(Float64, tₑ))
  SimulationResult(sys, dae, method, h, xs)
end


function initial_value(ic::AbstractDtry{Float64}, dae::DAESystem)
  x₀ = Vector{Float64}()
  foreach(dae.storage) do storage
    value = get(ic, storage.xvar.box_path * storage.xvar.port_path, nothing)
    isnothing(value) &&
      error("`ic` does not contain an initial condition for state $(storage.xvar.box_path * storage.xvar.port_path)")
    push!(x₀, value)
  end
  for (; residual) in dae.constraints
    expr = expand_flows_and_efforts_in_terms_of_states(residual, dae)
    evolution(dae, [x₀], expr)[1] ≈ 0 ||
      error("initial condition `ic` not consistent with constraint $(residual)")
  end
  λ₀ = zeros(Float64, length(dae.constraints))
  x = vcat(x₀, λ₀) # extended state vector
  SVector{length(x),Float64}(x)
end


"""
    timegrid(sim::SimulationResult)

Returns a `Vector{Float64}` of time instants
separated by the time step size `sim.h`.
"""
timegrid(sim::SimulationResult) = [i * sim.h for i in 0:length(sim.xs)-1]


expand_flows_and_efforts_in_terms_of_states(expr::SymExpr, dae::DAESystem) =
  replace(expr, Union{FVar,EVar}) do pvar
    index = findfirst(dae.storage) do (; xvar)
      pvar.box_path == xvar.box_path && pvar.port_path == xvar.port_path
    end
    if pvar isa FVar
      # Recursive call, since flow variables depend on effort variables
      # TODO deal with external port variables
      expand_flows_and_efforts_in_terms_of_states(dae.storage[index].flow, dae)
    else
      @assert pvar isa EVar
      # Effort variables depend on state variables
      dae.storage[index].effort
    end
  end


# Evolution of (functions of) the state variables
include("evolution.jl")


# Plotting methods defined in `ext/PlotsExt.jl`
function plot_evolution end
function plot_convergence end

end

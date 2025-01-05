module Simulations

using ForwardDiff: jacobian
using LinearAlgebra: norm
using RuntimeGeneratedFunctions
using StaticArrays

using ..AbstractSystems
using ..CompositeSystems
using ..SymbolicExpressions


export nlsolve
export compile_midpoint_update
export simulate
export Simulation


RuntimeGeneratedFunctions.init(@__MODULE__)


include("nlsolve.jl")


ast0(pvar::PortVar) = Symbol(replace(string(pvar), '.' => '₊') * "₀")
ast1(pvar::PortVar) = Symbol(replace(string(pvar), '.' => '₊') * "₁")


function compile_midpoint_update(sys::CompositeSystem)
  eqs = assemble(sys)

  xvars = (XVar(eq.lhs) for eq in eqs)

  expr_unpack_x₀ = Expr(
    :(=),
    Expr(
      :tuple,
      (ast0(xvar) for xvar in xvars)...
    ),
    :x₀
  )

  expr_unpack_x₁ = Expr(
    :(=),
    Expr(
      :tuple,
      (ast1(xvar) for xvar in xvars)...
    ),
    :x₁
  )

  expr_midpoint = Expr[
    Expr(
      :(=),
      ast(xvar),
      :( ($(ast0(xvar)) + $(ast1(xvar))) / 2 )
    )
    for xvar in xvars
  ]

  expr_residual = Expr[
    :(($(ast1(xvar)) - $(ast0(xvar))) - h * ($(ast(eq.rhs))))
    for (xvar, eq) in zip(xvars, eqs)
  ]

  expr_solve_x₁ = :(x₁ = nlsolve(residual, x₀))

  expr_update = Expr(
    :function,
    :(update(x₀, h)),
    Expr(
      :block,
      expr_unpack_x₀,
      Expr(
        :function,
        :(residual(x₁)),
        Expr(
          :block,
          expr_unpack_x₁,
          expr_midpoint...,
          Expr(
            :ref,
            :SA,
            expr_residual...
          )
        )
      ),
      expr_solve_x₁
    )
  )

  # println(expr_update)
  @RuntimeGeneratedFunction(expr_update)
end


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
  h::Float64
  xs::Vector
end


function simulate(sys::CompositeSystem, x₀::AbstractVector, h::Real, tₑ::Real)
  update = compile_midpoint_update(sys)
  ic = x₀ isa SVector ? x₀ : SVector{length(x₀),Float64}(x₀)
  xs = simulate(update, ic, convert(Float64, h), convert(Float64, tₑ))
  Simulation(sys, h, xs)
end


end

module PlotsExt

using EPHS, Plots


"""
    plot_evolution(
        sim::SimulationResult,
        exprs_or_pairs::Vararg{Union{SymExpr,Pair{String,<:SymExpr}}}
    )

Plot the time evolution of the given symbolic expressions,
which define functions of the state variables.
To use a custom label in the legend, supply a `Pair{String,SymExpr}`.
Keyword arguments are passed through to `Plots.plot`.
"""
function Simulations.plot_evolution(
  sim::SimulationResult,
  exprs_or_pairs::Vararg{Union{SymExpr,Pair{String,<:SymExpr}}};
  kwargs...
)
  ts = timegrid(sim)
  plt = plot(; xlabel="time [s]", kwargs...)
  foreach(exprs_or_pairs) do expr_or_pair
    label = expr_or_pair isa Pair ? first(expr_or_pair) : string(expr_or_pair)
    expr = expr_or_pair isa Pair ? last(expr_or_pair) : expr_or_pair
    plot!(plt, ts, evolution(sim, expr); label)
  end
  plt
end


"""
    plot_convergence(
        sys::CompositeSystem,
        ic::AbstractDtry{64},
        hs::Vector{Float64},
        t::Real,
        expr::SymExpr,
        error::Function,
        method::Function,
        ref::Vector{Int};
        ps::AbstractDtry{Float64}=Dtry{Float64}()
    )

Plot the convergence rate of a given integration method `mthd` for a system `sys`.
SymExpr `expr` defines a function over the simulation time `t`.
Function `error` evaluates the results of `eqn` over a set of time steps `hs`.
`ref` is the exponent of convergence rates used as references lines.
`ps` overwrites the parameter set of `sys`.
"""
function Simulations.plot_convergence(
  sys::CompositeSystem,
  ic::AbstractDtry{Float64},
  hs::Vector{Float64},
  t::Real,
  expr::SymExpr,
  error::Function,
  method::Function,
  ref::Vector{Int};
  ps::AbstractDtry{Float64}=Dtry{Float64}(),
  kwargs...
)
  plt = plot(; xscale=:log10, yscale=:log10, xlabel="h [s]", leg=:bottomright, kwargs...)
  err = map(hs) do h
    evolution(
      simulate(sys, method, ic, h, t; ps),
      expr
    ) |> error
  end
  plot!(plt, hs, err, label="error")
  for i in ref
    plot!(plt, hs, [h^i for h in hs], label="\$h^$i\$", ls=:dashdot)
  end
  plt
end


function Simulations.plot_convergence(
  sys::CompositeSystem,
  ic::AbstractDtry{Float64},
  hs::Vector{Float64},
  t::Real,
  error::Function,
  method::Function,
  ref::Vector{Int};
  ps::AbstractDtry{Float64}=Dtry{Float64}(),
  kwargs...
)
  plt = plot(; xscale=:log10, yscale=:log10, xlabel="h [s]", leg=:bottomright, kwargs...)
  err = map(hs) do h
    simulate(sys, method, ic, h, t; ps) |> error
  end
  plot!(plt, hs, err, label="error")
  for i in ref
    plot!(plt, hs, [h^i for h in hs], label="\$h^$i\$", ls=:dashdot)
  end
  plt
end

end

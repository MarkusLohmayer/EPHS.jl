
"""
    nlsolve(residual::Function, x₀::AbstractVector)

Solves the system of nonlinear equations `residual(x) ≈ 0`
using the Newton-Raphson method
with `x = x₀` as the initial guess.

# Example
```jldoctest
julia> using StaticArrays

julia> residual(x) = SA[x[1]-x[2]+2, x[1]*x[1]-x[2]];

julia> x₀ = SA[0., 0.];

julia> nlsolve(residual, x₀) ≈ SA[-1., 1.]
true
```
"""
function nlsolve(residual::Function, x::AbstractVector; tol::Float64=1e-12, maxiter::Int=100)
  res = residual(x)
  nrm = norm(res)
  cnt = 1
  while nrm > tol
    cnt < maxiter || error("nosolve: exceeded $maxiter iterations")
    jac = jacobian(residual, x)
    x = x - jac \ res
    res = residual(x)
    nrm = norm(res)
    cnt += 1
  end
  # @info i, nrm
  return x
end

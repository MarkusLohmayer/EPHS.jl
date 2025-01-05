
"""
Solve a system of nonlinear equations `residual(x) ≈ 0`
using the Newton-Raphson method.
Example:
```
using StaticArrays
function residual(x)
    x₁, x₂ = x
    SA[
        x₁-x₂+2,
        x₁*x₁-x₂
    ]
end
x = SA[0., 0.] # initial guess
@assert nlsolve(residual, x) ≈ SA[-1., 1.]
```
"""
function nlsolve(residual::Function, x::AbstractVector; tol::Float64=1e-12, maxiter::Int=100)
  res = residual(x)
  nrm = norm(res)
  cnt = 1
  while nrm > tol
    cnt < maxiter || error("nlsolve did not converge")
    jac = jacobian(residual, x)
    x = x - jac \ res
    res = residual(x)
    nrm = norm(res)
    cnt += 1
  end
  # @info i, nrm
  return x
end

module TestNLSolve

using Test, EPHS, StaticArrays


function residual(x)
  x₁, x₂ = x
  SA[
    x₁-x₂+2,
    x₁*x₁-x₂
  ]
end

@test nlsolve(residual, SA[0., 0.]) ≈ SA[-1., 1.]

end

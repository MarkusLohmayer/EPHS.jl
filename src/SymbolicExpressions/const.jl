
"""
    Const(value::Float64)

Wraps a `Float64` literal as a [`SymExpr`](@ref).
"""
struct Const <: SymVal
  value::Float64
end

Base.string(c::Const) = string(c.value)

ast(c::Const) = c.value

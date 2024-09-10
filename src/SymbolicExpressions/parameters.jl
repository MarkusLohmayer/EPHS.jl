# For now, we think about parameters as constants

struct Const <: SymExpr
  x::Float64
end

Base.string(s::Const) = string(s.x)

evaluate(s::Const) = s.x

ast(s::Const) = s.x

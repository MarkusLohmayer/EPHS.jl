
"Abstract type for (time-independent) parameters"
abstract type SymPar <: SymVar end

# For now, we think about parameters as constants
struct Const <: SymPar
  x::Float64
end

Base.string(s::Const) = string(s.x)

evaluate(s::Const) = s.x

ast(s::Const) = s.x

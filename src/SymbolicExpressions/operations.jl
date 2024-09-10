# Symbolic operations

## Unary

struct Neg <: SymOp
  s::SymExpr
end

Base.string(s::Neg) = "-(" * string(s.s) * ")"

evaluate(s::Neg) = -(evaluate(s.s))

ast(s::Neg) = :(-$(ast(s.s)))

Base.:-(s::SymExpr) = Neg(s)


struct Exp <: SymOp
  s::SymExpr
end

Base.string(s::Exp) = "exp(" * string(s.s) * ")"

evaluate(s::Exp) = exp(evaluate(s.s))

ast(s::Exp) = :(exp($(ast(s.s))))

Base.exp(s::SymExpr) = Exp(s)


## Binary

Base.:-(x::SymExpr, y::SymExpr) = Add(x, Neg(y))


struct Div <: SymOp
  num::SymExpr
  den::SymExpr
end

Base.string(s::Div) = "(" * string(s.num) * ") / (" * string(s.den) * ")"

evaluate(s::Div) = evaluate(s.num) / evaluate(s.den)

ast(s::Div) = :($(ast(s.num)) / $(ast(s.den)))

Base.:/(num::SymExpr, den::SymExpr) = Div(num, den)


## N-ary

struct Add <: SymOp
  ss::Tuple{Vararg{SymExpr}}
end

Add(ss::Vararg{SymExpr}) = Add(ss)

Base.string(s::Add) = join((string(s) for s in s.ss), " + ")

evaluate(s::Add) = foldl(+, (evaluate(s) for s in s.ss))

ast(s::Add) = :(+($((ast(s) for s in s.ss)...)))

Base.:+(ss::Vararg{SymExpr}) = Add(ss)



struct Mul <: SymOp
  ss::Tuple{Vararg{SymExpr}}
end

Mul(ss::Vararg{SymExpr}) = Mul(ss)

Base.string(s::Mul) = join((string(s) for s in s.ss), " * ")

evaluate(s::Mul) = foldl(*, (evaluate(s) for s in s.ss))

ast(s::Mul) = :(*($((ast(s) for s in s.ss)...)))

Base.:*(ss::Vararg{SymExpr}) = Mul(ss)


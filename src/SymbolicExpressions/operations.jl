# Symbolic operations

## Unary

struct Neg <: SymOp
  s::SymExpr
end

function Base.string(s::Neg)
  child = s.s isa SymVar ? string(s.s) : "(" * string(s.s) * ")"
  "-" * child
end

evaluate(s::Neg) = -(evaluate(s.s))

ast(s::Neg) = :(-$(ast(s.s)))

Base.:-(s::SymExpr) = Neg(s)

# Special 'constructor' for direct simplification
Neg(s::Neg) = s.s


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

function Base.string(s::Div)
  num = s.num isa SymVar ? string(s.num) : "(" * string(s.num) * ")"
  den = s.den isa SymVar ? string(s.den) : "(" * string(s.den) * ")"
  num * " / " * den
end

evaluate(s::Div) = evaluate(s.num) / evaluate(s.den)

ast(s::Div) = :($(ast(s.num)) / $(ast(s.den)))

Base.:/(num::SymExpr, den::SymExpr) = Div(num, den)


## N-ary

struct Add <: SymOp
  ss::Tuple{Vararg{SymExpr}}

  function Add(ss::Tuple{Vararg{SymExpr}})
    # flatten out nested `Add`s
    terms = Vector{SymExpr}()
    for s in ss
      if s isa Add
        append!(terms, s.ss)
      else
        push!(terms, s)
      end
    end
    # delete terms which cancel
    while delete_pm!(terms) end
    # simplify `Add` with a single term
    if length(terms) == 1
      return first(terms)
    else
      return new(Tuple(terms))
    end
  end
end

Add(ss::Vararg{SymExpr}) = Add(ss)

Base.string(s::Add) = join((string(s) for s in s.ss), " + ")

evaluate(s::Add) = foldl(+, (evaluate(s) for s in s.ss))

ast(s::Add) = :(+($((ast(s) for s in s.ss)...)))

Base.:+(ss::Vararg{SymExpr}) = Add(ss)

function delete_pm!(terms::Vector{SymExpr})
  for i in 1:length(terms)
    if terms[i] isa Neg
      for j in 1:length(terms)
        if terms[i].s == terms[j]
          deleteat!(terms, (i ≤ j) ? (i, j) : (j, i))
          return true
        end
      end
    end
  end
  return false
end



struct Mul <: SymOp
  ss::Tuple{Vararg{SymExpr}}
end

Mul(ss::Vararg{SymExpr}) = Mul(ss)

Base.string(s::Mul) = join((string(s) for s in s.ss), " * ")

evaluate(s::Mul) = foldl(*, (evaluate(s) for s in s.ss))

ast(s::Mul) = :(*($((ast(s) for s in s.ss)...)))

Base.:*(ss::Vararg{SymExpr}) = Mul(ss)


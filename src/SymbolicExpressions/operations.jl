# Symbolic operations

# Helper function:
# Add parentheses to `string` output for nested `SymOp`s (nodes),
# while leaving nested `SymVal`s (leaves) as is.
parenthesize(s::SymExpr)::String =
  s isa SymVal ? string(s) : "(" * string(s) * ")"

# The semantics of a SymExpr is defined by
# the `ast` function, which translates it to Julia syntax,
# and the semantics of the Julia syntax is in turn defined by
# multiple dispatch and the available methods for the respective function objects, here `-`.

# Add a method for the function object `-` in `Base`
# to easily construct symbolic expressions.
# For instance, with this and some `a::SymExpr`,
# you can call `-a` instead of `Neg(a)`

## Unary operations

Base.:-(s::SymExpr) = Mul(Const(-1), s)


struct Exp <: SymOp
  s::SymExpr
end

Base.string(s::Exp) = "exp(" * string(s.s) * ")"

ast(s::Exp) = :(exp($(ast(s.s))))

Base.exp(s::SymExpr) = Exp(s)

Base.diff(s::Exp, var::SymVar) = Mul(s, diff(s.s, var))


## Binary operations

Base.:-(s₁::SymExpr, s₂::SymExpr) = Add(s₁, Mul(Const(-1), s₂))

Base.:/(num::SymExpr, den::SymExpr) = Mul(num, Pow(den, Const(-1)))


struct Pow <: SymOp
  bas::SymExpr
  exp::SymExpr

  function Pow(bas::SymExpr, exp::SymExpr)
    exp isa Const && exp.value ≈ 1 && return bas
    if bas isa Pow
      bas, exp = bas.bas, bas.exp * exp
    end
    if bas isa Mul || exp isa Add
      ss_bas = bas isa Mul ? bas.ss : (bas,)
      ss_exp = exp isa Add ? exp.ss : (exp,)
      Mul((new(b, e) for b in ss_bas for e in ss_exp)...)
    else
      new(bas, exp)
    end
  end
end

Base.string(s::Pow) =
  parenthesize(s.bas) * "^" * parenthesize(s.exp)

ast(s::Pow) = :($(ast(s.bas))^$(ast(s.exp)))

Base.:^(bas::SymExpr, exp::SymExpr) = Pow(bas, exp)

function Base.diff(s::Pow, var::SymVar)
  (; bas, exp) = s
  foreach(exp, SymVar) do x
    x == var && error(
      "cannot differentiate wrt variable $(string(var)) in exponent $(string(exp))"
    )
  end
  return exp * bas^(exp-Const(1.)) * diff(bas, var)
end


## N-ary operations

struct Add <: SymOp
  ss::Tuple{Vararg{SymExpr}}

  function Add(ss::Tuple{Vararg{SymExpr}})
    value = Ref(0.) # sum of values of Const terms
    terms = OrderedDict{SymExpr,Float64}() # other terms with multiplicity/factor
    for s in ss
      _add_collect!(value, terms, s)
    end
    for (term, factor) in terms
      if factor ≈ 0
        delete!(terms, term)
      end
    end
    if length(terms) == 0
      return Const(value[])
    elseif length(terms) == 1
      term, factor = only(terms)
      if value[] ≈ 0
        return _add_emit(term, factor)
      else
        return new((Const(value[]), _add_emit(term, factor)))
      end
    else
      if value[] ≈ 0
        return new(((_add_emit(term, factor) for (term, factor) in terms)...,))
      else
        return new((Const(value[]), (_add_emit(term, factor) for (term, factor) in terms)...))
      end
    end
  end
end

function _add_collect!(value::Ref{Float64}, terms::OrderedDict{SymExpr,Float64}, s::SymExpr)
  if s isa Const
    value[] += s.value
  elseif s isa Add
    for x in s.ss
      _add_collect!(value, terms, x)
    end
  elseif s isa Mul && s.ss[1] isa Const
    factor = s.ss[1].value
    term = Mul(s.ss[2:end])
    terms[term] = get(terms, term, 0.) + factor
  else
    terms[s] = get(terms, s, 0.) + 1.
  end
  nothing
end

function _add_emit(term::SymExpr, factor::Float64)
  if factor ≈ 1.
    return term
  else
    return Mul(Const(factor), term)
  end
end

Add(ss::Vararg{SymExpr}) = Add(ss)

Base.string(s::Add) = join((string(s) for s in s.ss), " + ")

ast(s::Add) = :(+($((ast(s) for s in s.ss)...)))

Base.:+(ss::Vararg{SymExpr}) = Add(ss)

Base.diff(s::Add, var::SymVar) = Add((diff(x, var) for x in s.ss)...)


struct Mul <: SymOp
  ss::Tuple{Vararg{SymExpr}}

  function Mul(ss::Tuple{Vararg{SymExpr}})
    value = Ref(1.)
    terms = OrderedDict{SymExpr,Float64}() # terms with exponent
    for s in ss
      s isa Const && s.value ≈ 0 && return s
      _mul_collect!(value, terms, s)
    end
    for (term, exp) in terms
      if exp ≈ 0
        delete!(terms, term)
      end
    end
    if length(terms) == 0
      return Const(value[])
    elseif length(terms) == 1
      term, exp = only(terms)
      if value[] ≈ 1.
        return Pow(term, Const(exp))
      elseif term isa Add
        return Add((Const(value[]) * x for x in term.ss)...)
      else
        return new((Const(value[]), Pow(term, Const(exp))))
      end
    else
      if value[] ≈ 1.
        return new(((Pow(term, Const(exp)) for (term, exp) in terms)...,))
      else
        return new((Const(value[]), (Pow(term, Const(exp)) for (term, exp) in terms)...))
      end
    end
  end
end

function _mul_collect!(value::Ref{Float64}, terms::OrderedDict{SymExpr,Float64}, s::SymExpr)
  if s isa Const
    value[] *= s.value
  elseif s isa Mul
    for x in s.ss
      _mul_collect!(value, terms, x)
    end
  elseif s isa Pow && s.exp isa Const
    terms[s.bas] = get(terms, s.bas, 0) + s.exp.value
  else
    terms[s] = get(terms, s, 0) + 1
  end
  nothing
end

Mul(ss::Vararg{SymExpr}) = Mul(ss)

Base.string(s::Mul) = join((parenthesize(s) for s in s.ss), " * ")

ast(s::Mul) = :(*($((ast(s) for s in s.ss)...)))

Base.:*(ss::Vararg{SymExpr}) = Mul(ss)

function Base.diff(s::Mul, var::SymVar)
  result = Const(0)
  for i in 1:length(s.ss)
    l = s.ss[1:i-1]
    c = s.ss[i]
    r = s.ss[i+1:end]
    result = Add(
      result,
      Mul(l..., diff(c, var), r...)
    )
  end
  return result
end

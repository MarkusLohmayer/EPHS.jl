module TestSymbolicExpressions

using Test, EPHS.SymbolicExpressions

expr = Div(Const(42), Const(2))
@test expr == Const(42) / Const(2)
@test evaluate(expr) == 21.

f = buildfn((), expr) |> eval
@test f() == 21.



expr = Add(
  Const(1),
  Div(Const(3), Const(4))
)
expr2 = Add(
  Const(2),
  Div(Const(4), Const(5))
)
@test map(c -> Const(c.x + 1), expr, Const) == expr2


end

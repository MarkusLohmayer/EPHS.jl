module TestComponents

using Test
using EPHS.Directories, EPHS.SymbolicExpressions, EPHS.AbstractSystems, EPHS.Components
using EPHS.ComponentLibrary


## Storage components

@test relation(hookean_spring(k=1.5)) == Relation(
  storage = Dtry(
    Dtry(
      :q => Dtry{SymExpr}(FVar(■, ■.q))
    )
  ),
  ports = Dtry(
    :q => Dtry(Port(
      StateProvider(XVar(■, ■.q)),
      EffortProvider(Mul((Par(■, ■.k, 1.5), XVar(■, ■.q))))
    ))
  )
)


## Reversible components

@test relation(pkc) == Relation(
  ports = Dtry(
    :p => Dtry(Port(FlowProvider(EVar(■, ■.q)))),
    :q => Dtry(Port(FlowProvider(Mul((Const(-1.0), EVar(■, ■.p))))))
  )
)


mkc = let
  bₛ₊x = XVar(:bₛ)
  b₊e = EVar(:b)
  p₊e = EVar(:p)
  b₊f = bₛ₊x * p₊e
  p₊f = -(bₛ₊x * b₊e)
  ReversibleComponent(
    Dtry(
      :b => Dtry(ReversiblePort(FlowPort(magnetic_flux, b₊f))),
      :p => Dtry(ReversiblePort(FlowPort(angular_momentum, p₊f))),
      :bₛ => Dtry(ReversiblePort(StatePort(magnetic_flux)))
    )
  )
end;

@test relation(mkc) == Relation(
  ports = Dtry(
    :b => Dtry(Port(FlowProvider(Mul((XVar(■, ■.bₛ), EVar(■, ■.p)))))),
    :p => Dtry(Port(FlowProvider(Mul((Const(-1.0), XVar(■, ■.bₛ), EVar(■, ■.b)))))),
    :bₛ => Dtry(Port(StateConsumer()))
  )
)


@test relation(two_springs_series_connection) == Relation(
  constraints = Dtry(
    Dtry(
      :λ => Dtry{SymExpr}(Add((Mul((Const(-1.0), EVar(■, ■.q))), EVar(■, ■.q₂))))
    )
  ),
  ports = Dtry(
    :q => Dtry(Port(FlowProvider(CVar(■, ■.λ)))),
    :q₂ => Dtry(Port(FlowProvider(Mul((Const(-1.0), CVar(■, ■.λ))))))
  )
)


## Irreversible components

@test relation(linear_friction(d=0.02)) == Relation(
  ports = Dtry(
    :p => Dtry(Port(FlowProvider(Mul((Par(■, ■.d, 0.02), EVar(■, ■.p)))))),
    :s => Dtry(Port(FlowProvider(Mul((Const(-1.0), Par(■, ■.d, 0.02), Pow(EVar(■, ■.p), Const(2.0)), Pow(Add((Par(■.ENV, ■.θ, 300.0), EVar(■, ■.s))), Const(-1.0)))))))
  )
)


end

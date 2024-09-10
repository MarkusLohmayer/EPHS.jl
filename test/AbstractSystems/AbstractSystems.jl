module TestAbstractSystems

using Test, EPHS.AbstractSystems, EPHS.Directories, EPHS.SymbolicExpressions


if1 = Interface(
  :q => Interface(PortType(displacement, true)),
  :p => Interface(PortType(momentum, true)),
  :b => Interface(PortType(magnetic_flux, false)),
)



q = XVar(■, DtryPath(:q))
expr = Mul(Neg(Const(3)), q)
@test expr == -Const(3) * q

f = buildfn(q, expr) |> eval
@test f(1) == -3.

end

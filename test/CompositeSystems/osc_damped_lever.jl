
lever = Lever(Const(2.))

osc_damped_lever = CompositeSystem(
  Dtry{Tuple{Junction,Position}}(
    :q₁ => Dtry{Tuple{Junction,Position}}((
      Junction(false, displacement, true),
      Position(1,2)
    )),
    :q₂ => Dtry{Tuple{Junction,Position}}((
      Junction(false, displacement, true),
      Position(1,4)
    )),
    :p => Dtry{Tuple{Junction,Position}}((
      Junction(false, momentum, true),
      Position(1,6)
    )),
    :s => Dtry{Tuple{Junction,Position}}((
      Junction(false, entropy, true),
      Position(2,7)
    )),
  ),
  Dtry{Tuple{InnerBox{AbstractSystem},Position}}(
    :pe => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :q => Dtry{InnerPort}(InnerPort(■.q₁, true)),
        ),
        pe
      ),
      Position(1,1)
    )),
    :lever => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :q₁ => Dtry{InnerPort}(InnerPort(■.q₁, true)),
          :q₂ => Dtry{InnerPort}(InnerPort(■.q₂, true))
        ),
        lever
      ),
      Position(1,3)
    )),
    :pkc => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :q => Dtry{InnerPort}(InnerPort(■.q₂, true)),
          :p => Dtry{InnerPort}(InnerPort(■.p, true))
        ),
        pkc
      ),
      Position(1,5)
    )),
    :ke => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :p => Dtry{InnerPort}(InnerPort(■.p, true)),
        ),
        ke
      ),
      Position(1,7)
    )),
    :mf => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :p => Dtry{InnerPort}(InnerPort(■.p, true)),
          :s => Dtry{InnerPort}(InnerPort(■.s, true)),
        ),
        mf
      ),
      Position(2,6)
    )),
    :tc => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :s => Dtry{InnerPort}(InnerPort(■.s, true)),
        ),
        tc
      ),
      Position(2,8)
    )),
  )
)

@test assemble(osc_damped_lever) == Eq[
  Eq(FVar(■.pe, ■.q), Mul((Const(2.0), Div(XVar(■.ke, ■.p), Const(1.0))))),
  Eq(FVar(■.ke, ■.p), Neg(Add((Mul((Const(2.0), Mul((Const(1.5), XVar(■.pe, ■.q))))), Mul((Const(0.02), Div(XVar(■.ke, ■.p), Const(1.0)))))))),
  Eq(FVar(■.tc, ■.s), Div(Mul((Const(0.02), Div(XVar(■.ke, ■.p), Const(1.0)), Div(XVar(■.ke, ■.p), Const(1.0)))), Mul((Div(Const(1.0), Const(2.5)), Exp(Div(XVar(■.tc, ■.s), Const(2.5)))))))
]

# 32.083 μs (732 allocations: 22.30 KiB) top-down approach
# 18.833 μs (504 allocations: 15.91 KiB) hybrid approach, 41% less runtime
# 11.500 μs (345 allocations: 11.69 KiB) recursive approach, 64% less runtime than top-down approach
# @btime assemble($osc_damped_lever)

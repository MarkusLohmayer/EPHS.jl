module TestCompositeSystems

using Test, EPHS

# mechanical oscillator

pe = HookeanSpring(1.)
ke = PointMass(1.)
pkc = PKC()

osc = PreparedSystem(
  Dtry{Tuple{Junction,Position}}(
    :q => Dtry{Tuple{Junction,Position}}((
      Junction(false, displacement, true),
      Position(1,2)
    )),
    :p => Dtry{Tuple{Junction,Position}}((
      Junction(true, momentum, true),
      Position(1,4)
    )),
  ),
  Dtry{Tuple{InnerBox{AbstractSystem},Position}}(
    :pe => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :q => Dtry{InnerPort}(InnerPort(■.q, true)),
        ),
        pe
      ),
      Position(1,1)
    )),
    :ke => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :p => Dtry{InnerPort}(InnerPort(■.p, true)),
        ),
        ke
      ),
      Position(1,5)
    )),
    :pkc => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :q => Dtry{InnerPort}(InnerPort(■.q, true)),
          :p => Dtry{InnerPort}(InnerPort(■.p, true))
        ),
        pkc
      ),
      Position(1,3)
    )),
  )
)

@test get(osc, FVar(DtryPath(:pe), DtryPath(:q))) == -FVar(DtryPath(:pkc), DtryPath(:q))
@test get(osc, EVar(DtryPath(:pkc), DtryPath(:q))) == EVar(DtryPath(:pe), DtryPath(:q))

assemble(osc)


tc = ThermalCapacity(1., 2.5)
mf = LinearFriction(0.02)

damped_osc_flat = PreparedSystem(
  Dtry{Tuple{Junction,Position}}(
    :osc => Dtry{Tuple{Junction,Position}}(
      :q => Dtry{Tuple{Junction,Position}}((
        Junction(false, displacement, true),
        Position(1,2)
      )),
    ),
    :p => Dtry{Tuple{Junction,Position}}((
      Junction(false, momentum, true),
      Position(1,4)
    )),
    :s => Dtry{Tuple{Junction,Position}}((
      Junction(false, entropy, true),
      Position(2,5)
    )),
  ),
  Dtry{Tuple{InnerBox{AbstractSystem},Position}}(
    :osc => Dtry{Tuple{InnerBox{AbstractSystem},Position}}(
      :pe => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
        InnerBox{AbstractSystem}(
          Dtry{InnerPort}(
            :q => Dtry{InnerPort}(InnerPort(■.osc.q, true)),
          ),
          pe
        ),
        Position(1,1)
      )),
      :ke => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
        InnerBox{AbstractSystem}(
          Dtry{InnerPort}(
            :p => Dtry{InnerPort}(InnerPort(■.p, true)),
          ),
          ke
        ),
        Position(1,5)
      )),
      :pkc => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
        InnerBox{AbstractSystem}(
          Dtry{InnerPort}(
            :q => Dtry{InnerPort}(InnerPort(■.osc.q, true)),
            :p => Dtry{InnerPort}(InnerPort(■.p, true))
          ),
          pkc
        ),
        Position(1,3)
      )),
    ),
    :mf => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :p => Dtry{InnerPort}(InnerPort(■.p, true)),
          :s => Dtry{InnerPort}(InnerPort(■.s, true)),
        ),
        mf
      ),
      Position(2,4)
    )),
    :tc => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :s => Dtry{InnerPort}(InnerPort(■.s, true)),
        ),
        tc
      ),
      Position(2,6)
    )),
  )
);


end


# mechanical oscillator

pe = HookeanSpring(1.)
ke = PointMass(1.)
pkc = PKC()

osc = CompositeSystem(
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

assemble(osc)


tc = ThermalCapacity(1., 2.5)
mf = LinearFriction(0.02)

osc_damped_flat = CompositeSystem(
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

assemble(osc_damped_flat)

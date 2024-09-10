module TestPatterns

using Test, EPHS.Patterns, EPHS.AbstractSystems, EPHS.Directories


osc = Pattern{Nothing,Position}(
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
  Dtry{Tuple{InnerBox{Nothing},Position}}(
    :pe => Dtry{Tuple{InnerBox{Nothing},Position}}((
      InnerBox{Nothing}(
        Dtry{InnerPort}(
          :q => Dtry{InnerPort}(InnerPort(■.q, true)),
        ),
        nothing
      ),
      Position(1,1)
    )),
    :ke => Dtry{Tuple{InnerBox{Nothing},Position}}((
      InnerBox{Nothing}(
        Dtry{InnerPort}(
          :p => Dtry{InnerPort}(InnerPort(■.p, true)),
        ),
        nothing
      ),
      Position(1,5)
    )),
    :pkc => Dtry{Tuple{InnerBox{Nothing},Position}}((
      InnerBox{Nothing}(
        Dtry{InnerPort}(
          :q => Dtry{InnerPort}(InnerPort(■.q, true)),
          :p => Dtry{InnerPort}(InnerPort(■.p, true))
        ),
        nothing
      ),
      Position(1,3)
    )),
  )
)


damped_osc = Pattern{Nothing,Position}(
  Dtry{Tuple{Junction,Position}}(
    :p => Dtry{Tuple{Junction,Position}}((
      Junction(false, momentum, true),
      Position(1,2)
    )),
    :s => Dtry{Tuple{Junction,Position}}((
      Junction(false, entropy, true),
      Position(1,4)
    )),
  ),
  Dtry{Tuple{InnerBox{Nothing},Position}}(
    :osc => Dtry{Tuple{InnerBox{Nothing},Position}}((
      InnerBox{Nothing}(
        Dtry{InnerPort}(
          :p => Dtry{InnerPort}(InnerPort(■.p, true)),
        ),
        nothing
      ),
      Position(1,1)
    )),
    :mf => Dtry{Tuple{InnerBox{Nothing},Position}}((
      InnerBox{Nothing}(
        Dtry{InnerPort}(
          :p => Dtry{InnerPort}(InnerPort(■.p, true)),
          :s => Dtry{InnerPort}(InnerPort(■.s, true)),
        ),
        nothing
      ),
      Position(1,3)
    )),
    :tc => Dtry{Tuple{InnerBox{Nothing},Position}}((
      InnerBox{Nothing}(
        Dtry{InnerPort}(
          :s => Dtry{InnerPort}(InnerPort(■.s, true)),
        ),
        nothing
      ),
      Position(1,5)
    )),
  )
)


damped_osc_flat = Pattern{Nothing,Position}(
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
  Dtry{Tuple{InnerBox{Nothing},Position}}(
    :osc => Dtry{Tuple{InnerBox{Nothing},Position}}(
      :pe => Dtry{Tuple{InnerBox{Nothing},Position}}((
        InnerBox{Nothing}(
          Dtry{InnerPort}(
            :q => Dtry{InnerPort}(InnerPort(■.osc.q, true)),
          ),
          nothing
        ),
        Position(1,1)
      )),
      :ke => Dtry{Tuple{InnerBox{Nothing},Position}}((
        InnerBox{Nothing}(
          Dtry{InnerPort}(
            :p => Dtry{InnerPort}(InnerPort(■.p, true)),
          ),
          nothing
        ),
        Position(1,5)
      )),
      :pkc => Dtry{Tuple{InnerBox{Nothing},Position}}((
        InnerBox{Nothing}(
          Dtry{InnerPort}(
            :q => Dtry{InnerPort}(InnerPort(■.osc.q, true)),
            :p => Dtry{InnerPort}(InnerPort(■.p, true))
          ),
          nothing
        ),
        Position(1,3)
      )),
    ),
    :mf => Dtry{Tuple{InnerBox{Nothing},Position}}((
      InnerBox{Nothing}(
        Dtry{InnerPort}(
          :p => Dtry{InnerPort}(InnerPort(■.p, true)),
          :s => Dtry{InnerPort}(InnerPort(■.s, true)),
        ),
        nothing
      ),
      Position(2,4)
    )),
    :tc => Dtry{Tuple{InnerBox{Nothing},Position}}((
      InnerBox{Nothing}(
        Dtry{InnerPort}(
          :s => Dtry{InnerPort}(InnerPort(■.s, true)),
        ),
        nothing
      ),
      Position(2,6)
    )),
  )
)

@test interface(damped_osc_flat) == Interface()
@test interface(damped_osc_flat, ■.osc.ke) == Interface(
  :p => Interface(PortType(momentum, true))
)


# @test compose(damped_osc.osc => osc) == damped_osc_flat


# Test composition with identity

end

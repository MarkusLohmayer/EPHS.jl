
osc_damped_nested = CompositeSystem(
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
  Dtry{Tuple{InnerBox{AbstractSystem},Position}}(
    :osc => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :p => Dtry{InnerPort}(InnerPort(■.p, true)),
        ),
        osc
      ),
      Position(1,1)
    )),
    :mf => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :p => Dtry{InnerPort}(InnerPort(■.p, true)),
          :s => Dtry{InnerPort}(InnerPort(■.s, true)),
        ),
        mf
      ),
      Position(1,3)
    )),
    :tc => Dtry{Tuple{InnerBox{AbstractSystem},Position}}((
      InnerBox{AbstractSystem}(
        Dtry{InnerPort}(
          :s => Dtry{InnerPort}(InnerPort(■.s, true)),
        ),
        tc
      ),
      Position(1,5)
    )),
  )
)

@test assemble(osc_damped_nested) == assemble(osc_damped_flat)

# 50.625 μs (781 allocations: 27.59 KiB)
# @btime assemble($osc_damped_nested)

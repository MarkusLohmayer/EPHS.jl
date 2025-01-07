
osc_damped_nested = CompositeSystem(
  Dtry(
    :p => Dtry(Junction(momentum, Position(1,2))),
    :s => Dtry(Junction(entropy, Position(1,4))),
  ),
  Dtry(
    :osc => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        osc,
        Position(1,1)
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :s => Dtry(InnerPort(■.s)),
        ),
        mf,
        Position(1,3)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        tc,
        Position(1,5)
      ),
    ),
  )
);

@test osc_damped_nested.isflat == false

@test assemble(osc_damped_nested) == assemble(osc_damped_flat)

# 50.625 μs (781 allocations: 27.59 KiB) two levels of nesting
# 85.041 μs (1265 allocations: 45.20 KiB) arbitrary nesting of patterns
# 59.625 μs (949 allocations: 33.41 KiB) isflat
# 57.958 μs (891 allocations: 31.30 KiB) refactor Position, convenience constructors
# 67.375 μs (1050 allocations: 35.80 KiB) components as values, dtry
# 68.041 μs (1018 allocations: 35.72 KiB) DAESystem
# 137.625 μs (1973 allocations: 70.14 KiB) Symbolic differentiation (with simplification/normalization)
# @btime assemble($osc_damped_nested);

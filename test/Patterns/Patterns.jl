module TestPatterns

using Test, EPHS.Patterns, EPHS.AbstractSystems, EPHS.Directories


osc = Pattern(
  Dtry(
    :q => Dtry(Junction(displacement, Position(1,2))),
    :p => Dtry(Junction(momentum, Position(1,4), exposed=true)),
  ),
  Dtry(
    :pe => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
        ),
        Position(1,1)
      ),
    ),
    :ke => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        Position(1,5)
      ),
    ),
    :pkc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
          :p => Dtry(InnerPort(■.p))
        ),
        Position(1,3)
      ),
    ),
  )
);


damped_osc = Pattern(
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
        Position(1,1)
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :s => Dtry(InnerPort(■.s)),
        ),
        Position(1,3)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        Position(1,5)
      ),
    ),
  )
);


damped_osc_flat = Pattern(
  Dtry(
    :p => Dtry(Junction(momentum, Position(1,4))),
    :s => Dtry(Junction(entropy, Position(2,5))),
    :osc => Dtry(
      :q => Dtry(Junction(displacement, Position(1,2))),
    ),
  ),
  Dtry(
    :osc => Dtry(
      :pe => Dtry(
        InnerBox(
          Dtry(
            :q => Dtry(InnerPort(■.osc.q)),
          ),
          Position(1,1)
        ),
      ),
      :ke => Dtry(
        InnerBox(
          Dtry(
            :p => Dtry(InnerPort(■.p)),
          ),
          Position(1,5)
        ),
      ),
      :pkc => Dtry(
        InnerBox(
          Dtry(
            :q => Dtry(InnerPort(■.osc.q)),
            :p => Dtry(InnerPort(■.p))
          ),
          Position(1,3)
        ),
      ),
    ),
    :mf => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
          :s => Dtry(InnerPort(■.s)),
        ),
        Position(2,4)
      ),
    ),
    :tc => Dtry(
      InnerBox(
        Dtry(
          :s => Dtry(InnerPort(■.s)),
        ),
        Position(2,6)
      ),
    ),
  )
);

@test interface(damped_osc_flat) == Interface()
@test interface(damped_osc_flat, ■.osc.ke) == Interface(
  :p => Interface(PortType(momentum, true))
)




# Composition and identity

const P = Pattern{Nothing,Nothing}

osc = P(osc);

# identity pattern on the interface of the box `pkc` of the pattern `osc`
id_pkc = identity(interface(osc, ■.pkc));
@test interface(id_pkc) == interface(osc, ■.pkc)
@test interface(id_pkc) == interface(id_pkc, ■)


id_pe = identity(interface(osc, ■.pe));
id_ke = identity(interface(osc, ■.ke));

@test compose(osc, Dtry{P}(
  :pe => Dtry{P}(id_pe),
  :ke => Dtry{P}(id_ke),
  :pkc => Dtry{P}(id_pkc),
)) == osc

damped_osc = P(damped_osc);
damped_osc_flat = P(damped_osc_flat);

id_mf = identity(interface(damped_osc, ■.mf));
id_tc = identity(interface(damped_osc, ■.tc));

@test compose(damped_osc, Dtry{P}(
  :osc => Dtry{P}(osc),
  :mf => Dtry{P}(id_mf),
  :tc => Dtry{P}(id_tc),
)) == damped_osc_flat

end

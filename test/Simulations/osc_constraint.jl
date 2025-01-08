# mechanical oscillator with constraint (two springs in series)

hc = ReversibleComponent(
  Dtry(
    :q => Dtry(ReversiblePort(FlowPort(displacement, CVar(:λ)))),
    :q₂ => Dtry(ReversiblePort(FlowPort(displacement, -CVar(:λ)))),
    :λ => Dtry(ReversiblePort(Constraint(-EVar(:q) + EVar(:q₂))))
  )
);

osc_constraint = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(false, displacement, true, Position(1,2))),
    :p => Dtry(Junction(false, momentum, true, Position(1,4))),
    :q₂ => Dtry(Junction(false, displacement, true, Position(3,2))),
  ),
  Dtry(
    :pe => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q, true)),
        ),
        pe,
        Position(1,1)
      ),
    ),
    :ke => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p, true)),
        ),
        ke,
        Position(1,5)
      ),
    ),
    :pkc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q, true)),
          :p => Dtry(InnerPort(■.p, true))
        ),
        pkc,
        Position(1,3)
      ),
    ),
    :hc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q, true)),
          :q₂ => Dtry(InnerPort(■.q₂, true)),
        ),
        hc,
        Position(2,2)
      ),
    ),
    :pe₂ => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q₂, true)),
        ),
        pe,
        Position(3,1)
      ),
    ),
  )
);

function update_hand(x₀, h)
  q₀, p₀, λ₀ = x₀
  function residual(x₁)
    q₁, p₁, λ₁ = x₁
    q = (q₀ + q₁) / 2
    p = (p₀ + p₁) / 2
    SA[
      (q₁-q₀)-h*(p/1.),
      (p₁-p₀)-h*(-1.5q),
    ]
  end
  x₁ = nlsolve(residual, x₀)
end

update_prog = compile_midpoint_update(osc)

xs_hand = simulate(update_hand, SA[1., 0.], 0.01, 10.0)

xs_prog = simulate(update_prog, SA[1., 0.], 0.01, 10.0)

@test xs_hand == xs_prog

@test xs_prog == simulate(osc, [1, 0], 0.01, 10).xs

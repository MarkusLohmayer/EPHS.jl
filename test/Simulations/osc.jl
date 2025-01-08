
pe = StorageComponent(
  Dtry(
    :q => Dtry(StoragePort(displacement, Const(1.5) * XVar(:q)))
  )
);

ke = StorageComponent(
  Dtry(
    :p => Dtry(StoragePort(momentum, XVar(:p) / Const(1.0)))
  )
);

pkc = ReversibleComponent(
  Dtry(
    :q => Dtry(ReversiblePort(FlowPort(displacement, -EVar(:p)))),
    :p => Dtry(ReversiblePort(FlowPort(momentum, EVar(:q))))
  )
);

osc = CompositeSystem(
  Dtry(
    :q => Dtry(Junction(displacement, Position(1, 2))),
    :p => Dtry(Junction(momentum, Position(1, 4))),
  ),
  Dtry(
    :pe => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
        ),
        pe,
        Position(1, 1)
      ),
    ),
    :ke => Dtry(
      InnerBox(
        Dtry(
          :p => Dtry(InnerPort(■.p)),
        ),
        ke,
        Position(1, 5)
      ),
    ),
    :pkc => Dtry(
      InnerBox(
        Dtry(
          :q => Dtry(InnerPort(■.q)),
          :p => Dtry(InnerPort(■.p))
        ),
        pkc,
        Position(1, 3)
      ),
    ),
  )
);


function update_hand(x₀, h)
  q₀, p₀ = x₀
  function residual(x₁)
    q₁, p₁ = x₁
    q = (q₀ + q₁) / 2
    p = (p₀ + p₁) / 2
    SA[
      (q₁-q₀)-h*(p/1.),
      (p₁-p₀)-h*(-1.5q),
    ]
  end
  x₁ = nlsolve(residual, x₀)
end

update_prog = midpoint_rule(osc)

xs_hand = simulate(update_hand, SA[1., 0.], 0.01, 10.0)

xs_prog = simulate(update_prog, SA[1., 0.], 0.01, 10.0)

@test xs_hand == xs_prog

@test xs_prog == simulate(osc, midpoint_rule, [1, 0], 0.01, 10).xs

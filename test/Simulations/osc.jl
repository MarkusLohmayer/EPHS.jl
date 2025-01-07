
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
  p₀, q₀ = x₀
  function residual(x₁)
    p₁, q₁ = x₁
    p = (p₀ + p₁) / 2
    q = (q₀ + q₁) / 2
    SA[
      (p₁-p₀)-h*(-1.5q),
      (q₁-q₀)-h*(p/1.0),
    ]
  end
  x₁ = nlsolve(residual, x₀)
end


dae = assemble(osc);
update_prog = midpoint_rule(dae)
x₀ = SA[0.0, 1.0] # [p₀, q₀]
h = 0.01
t = 10.0
xs_hand = simulate(update_hand, x₀, h, t)
xs_prog = simulate(update_prog, x₀, h, t)
@test xs_hand == xs_prog

# Higher-level interface
# Initial conditions as directory
ic = Dtry(
  :pe => Dtry(
    :q => Dtry(1.0),
  ),
  :ke => Dtry(
    :p => Dtry(0.0),
  ),
);
sim_osc = simulate(osc, midpoint_rule, ic, h, t);
@test xs_prog == sim_osc.xs

# using Plots
# q = XVar(DtryPath(:pe), DtryPath(:q))
# p = XVar(DtryPath(:ke), DtryPath(:p))
# plot_evolution(sim_osc, q, p)


using ..TestCompositeSystems: osc_damped_flat

ics = Dtry(
  :osc => Dtry(
    :pe => Dtry(
      :q => Dtry(1.0),
    ),
    :ke => Dtry(
      :p => Dtry(0.0),
    ),
  ),
  :tc => Dtry(
    :s => Dtry(16.56)
  ),
);
sim = simulate(osc_damped_flat, midpoint_rule, ics, 0.01, 20);

# using Plots
# q = XVar(DtryPath(:osc, :pe), DtryPath(:q))
# p = XVar(DtryPath(:osc, :ke), DtryPath(:p))
# s = XVar(DtryPath(:tc), DtryPath(:s))
# plot_evolution(sim, q)
# plot_evolution(sim, s)

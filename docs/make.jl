using Documenter
using EPHS
using Plots


DocMeta.setdocmeta!(EPHS, :DocTestSetup, :(using EPHS); recursive=true)


makedocs(
  sitename="EPHS.jl",
  authors="Markus Lohmayer <markus.lohmayer@fau.de>",
  format=Documenter.HTML(
    canonical="https://MarkusLohmayer.github.io/EPHS.jl/stable",
  ),
  modules=[
    Directories,
    SymbolicExpressions,
    AbstractSystems,
    Patterns,
    Components,
    CompositeSystems,
    Simulations,
    Base.get_extension(EPHS, :PlotsExt),
    ComponentLibrary,
  ],
  pages=[
    "Home" => "index.md",
    "Background" => [
      "Overview" => "Background/Overview.md",
      "Background/EnergyBased.md",
      "Background/PortBased.md",
      "Background/Discussion.md",
      "Background/Approach.md",
    ],
    "Fundamentals" => [
      "Overview" => "Fundamentals/Overview.md",
      "Fundamentals/Directories.md",
      "Fundamentals/Patterns.md",
      "Fundamentals/Components.md",
    ],
    "Examples" => [
      "Overview" => "Examples/Overview.md",
      "Examples/Oscillator.md",
      "Examples/Oscillator_constraint.md",
      "Examples/CPD.md",
      "Examples/Motor.md",
    ],
    "Vision" => "Vision.md",
    "Reference" => [
      "Overview" => "Reference/Overview.md",
      "Reference/Directories.md",
      "Reference/SymbolicExpressions.md",
      "Reference/AbstractSystems.md",
      "Reference/Patterns.md",
      "Reference/Components.md",
      "Reference/CompositeSystems.md",
      "Reference/Simulations.md",
      "Reference/ComponentLibrary.md",
    ],
  ],
)


deploydocs(
  repo="github.com/MarkusLohmayer/EPHS.jl",
)

module EPHS

using Reexport

# Things that we miss in Base
include("MoreBase.jl")

# Tuple-backed dictionaries
include("TupleDicts.jl")

# Directories with separate index (tree) and data (stored in a flat tuple)
include("Directories/Directories.jl")

# Mathematical expressions used to define semantics
include("SymbolicExpressions/SymbolicExpressions.jl")

# Quantities, interfaces, and abstract system type
include("AbstractSystems/AbstractSystems.jl")

# Graphical syntax
include("Patterns/Patterns.jl")

# Exergy reference environment
include("Environment.jl")

# Primitive systems
include("Components/Components.jl")

# Composite systems
include("CompositeSystems/CompositeSystems.jl")

# Numerical integration
include("Simulations/Simulations.jl")


@reexport using .MoreBase
@reexport using .TupleDicts

@reexport using .Directories
@reexport using .SymbolicExpressions

@reexport using .AbstractSystems

@reexport using .Patterns

@reexport using .Environment
@reexport using .Components

@reexport using .CompositeSystems

@reexport using .Simulations

end

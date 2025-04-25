@doc read(joinpath(dirname(@__DIR__), "README.md"), String)
module EPHS

using Reexport

# Things that would be nice to have in Base
include("MoreBase.jl")

# Tuple-backed dictionaries
include("TupleDicts.jl")

# Directories - the monadic data structure behind EPHS.jl
include("Directories/Directories.jl")

# Mathematical syntax for expressing equations/relations that define the semantics
include("SymbolicExpressions/SymbolicExpressions.jl")

# Quantities, interfaces, abstract system type, and port variables
include("AbstractSystems/AbstractSystems.jl")

# Compositional, graphical syntax
include("Patterns/Patterns.jl")

# Primitive systems (storage/reversible/irreversible)
include("Components/Components.jl")

# Composite systems (filled patterns, assembly of systems of equations)
include("CompositeSystems/CompositeSystems.jl")

# Numerical integration, post-processing
include("Simulations/Simulations.jl")

# Standard library for components
include("ComponentLibrary/ComponentLibrary.jl")


@reexport using .MoreBase

@reexport using .TupleDicts

@reexport using .Directories

@reexport using .SymbolicExpressions

@reexport using .AbstractSystems

@reexport using .Patterns

@reexport using .Components

@reexport using .CompositeSystems

@reexport using .Simulations

@reexport using .ComponentLibrary

end

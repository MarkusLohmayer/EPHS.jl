using Test

@testset "MoreBase" begin
  include("MoreBase.jl")
end

@testset "TupleDicts" begin
  include("TupleDicts.jl")
end

@testset "Directories" begin
  include("Directories/Directories.jl")
end

@testset "AbstractSystems" begin
  include("AbstractSystems/AbstractSystems.jl")
end

@testset "Patterns" begin
  include("Patterns/Patterns.jl")
end

@testset "SymbolicExpressions" begin
  include("SymbolicExpressions/SymbolicExpressions.jl")
end

# @testset "Environment" begin
#   include("Environment.jl")
# end

# @testset "Components" begin
#   include("Components/Components.jl")
# end

@testset "CompositeSystems" begin
  include("CompositeSystems/CompositeSystems.jl")
end

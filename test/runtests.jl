using Test

@testset "MoreBase" begin
  include("TestMoreBase.jl")
end

@testset "TupleDicts" begin
  include("TestTupleDicts.jl")
end

@testset "Directories" begin
  include("Directories/TestDirectories.jl")
end

# @testset "AbstractSystems" begin
#   include("AbstractSystems/TestAbstractSystems.jl")
# end

@testset "Patterns" begin
  include("Patterns/TestPatterns.jl")
end

# @testset "SymbolicExpressions" begin
#   include("SymbolicExpressions/TestSymbolicExpressions.jl")
# end

# @testset "Components" begin
#   include("Components/TestComponents.jl")
# end

@testset "CompositeSystems" begin
  include("CompositeSystems/TestOsc.jl")
  include("CompositeSystems/TestOscLever.jl")
  include("CompositeSystems/TestOscSprings.jl")
  include("CompositeSystems/TestMotor.jl")
end

@testset "Simulations" begin
  include("Simulations/TestNLSolve.jl")
  include("Simulations/TestSimOsc.jl")
  include("Simulations/TestSimOscSprings.jl")
  include("Simulations/TestCPD.jl")
end

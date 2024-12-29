module SymbolicExpressions

export SymExpr
export evaluate, ast
export SymVar, SymOp
export Eq

# operations
export Neg, Exp
export Div
export Add, Mul

# parameters
export SymPar, Const

# code generation
export buildfn



"Abstract symbolic expression"
abstract type SymExpr end


# API for SymExpr
Base.string(::SymExpr) = error("Not implemented")
evaluate(::SymExpr) = error("Not implemented")
ast(::SymExpr) = error("Not implemented")


Base.print(io::IO, s::SymExpr) = print(io, string(s))


"""
Abstract symbolic variable (has no child expressions)
"""
abstract type SymVar <: SymExpr end


"""
Abstract symbolic operation (has child expressions)
"""
abstract type SymOp <: SymExpr end


"Symbolic equation"
struct Eq
  lhs::SymExpr
  rhs::SymExpr
end


# Base.show(io::IO, ::MIME"text/plain", eq::Eq) =
Base.print(io::IO, eq::Eq) = print(io, eq.lhs, " = ", eq.rhs)

Base.print(io::IO, eqs::Vector{Eq}) = foreach(eq -> println(eq), eqs)


# Symbolic operations
include("operations.jl")

# Symbolic parameters (constants)
include("parameters.jl")

# Transform expressions
include("map.jl")

# Turn expressions with variables into Julia functions
include("code_generation.jl")

end

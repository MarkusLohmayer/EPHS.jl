"""
The `SymblicExpressions` module provides
a simple computer algebra system (CAS).
The concrete subtypes of [`SymExpr`](@ref) provide
a mathematical syntax to symbolically represent
the relations that define the semantics of
primitive and composite systems.
"""
module SymbolicExpressions

export SymExpr
export ast
export SymOp, SymVal, SymVar
export Eq

# operations
export Neg, Exp
export Div, Pow
export Add, Mul

# constants
export Const


using OrderedCollections: OrderedDict



"""
Abstract supertype for symbolic expressions.
Abstract subtypes are [`SymVal`](@ref)
for all leaf nodes (values) that may appear in syntax trees
and [`SymOp`](@ref)
for all internal nodes (operations) of a `SymExpr`.
"""
abstract type SymExpr end


# API for SymExpr:

Base.string(::SymExpr) = error("Not implemented")


"""
    ast(s::SymExpr) -> Expr

Transform a [`SymExpr`](@ref) into a Julia `Expr`.
Together with the methods called in the returned Julia `Expr`,
`ast` defines the semantics of the mathematical `SymExpr` syntax.
"""
ast(::SymExpr) = error("Not implemented")



Base.print(io::IO, s::SymExpr) = print(io, string(s))


"""
Abstract type for symbolic operations,
i.e. internal nodes in a [`SymExpr`](@ref) syntax tree.
"""
abstract type SymOp <: SymExpr end


"""
Abstract type for symbolic values,
i.e. leaf nodes in a [`SymExpr`](@ref) syntax tree.
"""
abstract type SymVal <: SymExpr end


"""
Abstract subtype of [`SymVal`](@ref) for symbolic variables,
such as port variables, constraint variables, and parameters.
"""
abstract type SymVar <: SymVal end


"""
    diff(expr::SymExpr, var::SymVar) -> SymExpr

Returns the derivative of the given [`SymExpr`](@ref)
with respect to the given [`SymVar`](@ref)
using symbolic differentiation.
"""
Base.diff(::SymExpr, ::SymVar) = error("differentiation of $(typeof(s)) not implemented")
# Symbolic differentiation of
# - symbolic variables
Base.diff(s1::SymVar, s2::SymVar) = s1 == s2 ? Const(1.) : Const(0.)
# - constant literals
Base.diff(::SymVal, ::SymVar) = Const(0.)


"""
    Eq(lhs::SymExpr, rhs::SymExpr)

Equation with a [`SymExpr`](@ref) on both sides of the equal sign.

# Fields
- `lhs`: left hand side
- `rhs`: right hand side
"""
struct Eq
  lhs::SymExpr
  rhs::SymExpr
end

# print symbolic equations
Base.print(io::IO, eq::Eq) = print(io, eq.lhs, " = ", eq.rhs)

# print each line of a equation vector
Base.print(io::IO, eqs::Vector{Eq}) = foreach(eq -> println(io, eq), eqs)


# Symbolic operations
include("operations.jl")

# Numeric literals
include("const.jl")

# Transform expression trees
include("map.jl")

end

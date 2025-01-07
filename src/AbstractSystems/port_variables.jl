
"""
`PortVar` is a supertype for port variables.
Its concrete subtypes are
- [`XVar`](@ref) for state variables
- [`FVar`](@ref) for flow variables
- [`EVar`](@ref) for effort variables
"""
abstract type PortVar <: SymVar end


Base.show(io::IO, ::MIME"text/plain", var::PortVar) = print(io, string(var))


"""
    XVar(box_path::DtryPath, port_path::DtryPath)

A `XVar` represents a state variable of a port.

# Fields
- `box_path`: name of the [`EPHS.Patterns.InnerBox`](@ref) or system
    to which the port belongs
- `port_path`: name of the port itself
    relative to the box or system interface

Hence, the full path identifying the port is `box_path * port_path`.
Both parts are stored separately to prevent ambiguities.
"""
struct XVar <: PortVar
  box_path::DtryPath
  port_path::DtryPath
end


"""
`PowerVar` is a subtype of `PortVar`.
Concrete subtypes of `PowerVar` are
- [`FVar`](@ref) for flow variables
- [`EVar`](@ref) for effort variables
"""
abstract type PowerVar <: PortVar end


"""
    FVar(box_path::DtryPath, port_path::DtryPath)

A `FVar` represents a flow variable of a port.
See [`XVar`](@ref) for info about
the fields `box_path` and `port_path`.
"""
struct FVar <: PowerVar
  box_path::DtryPath
  port_path::DtryPath
end


"""
    EVar(box_path::DtryPath, port_path::DtryPath)

An `EVar` represents an effort variable of a port.
See [`XVar`](@ref) for info about
the fields `box_path` and `port_path`.
"""
struct EVar <: PowerVar
  box_path::DtryPath
  port_path::DtryPath
end


Base.string(x::XVar) = string(x.box_path * x.port_path) * ".x"
Base.string(f::FVar) = string(f.box_path * f.port_path) * ".f"
Base.string(e::EVar) = string(e.box_path * e.port_path) * ".e"


SymbolicExpressions.ast(pvar::PortVar) =
  Symbol(replace(string(pvar), '.' => '₊'))


XVar(port_name::Symbol) = XVar(DtryPath(), DtryPath(port_name))
FVar(port_name::Symbol) = FVar(DtryPath(), DtryPath(port_name))
EVar(port_name::Symbol) = EVar(DtryPath(), DtryPath(port_name))


XVar(pvar::PortVar) = XVar(pvar.box_path, pvar.port_path)
FVar(pvar::PortVar) = FVar(pvar.box_path, pvar.port_path)
EVar(pvar::PortVar) = EVar(pvar.box_path, pvar.port_path)


"State, flow, and effort variables are port variables"
abstract type PortVar <: SymVar end


Base.show(io::IO, ::MIME"text/plain", var::PortVar) = print(io, string(var))


"Flow and effort variables are power variables"
abstract type PowerVar <: PortVar end


"State variable"
struct XVar <: PortVar
  box_path::DtryPath
  port_path::DtryPath
end


"Flow variable"
struct FVar <: PowerVar
  box_path::DtryPath
  port_path::DtryPath
end


"Effort variable"
struct EVar <: PowerVar
  box_path::DtryPath
  port_path::DtryPath
end


Base.string(x::XVar) = string(x.box_path * x.port_path) * ".x"
Base.string(f::FVar) = string(f.box_path * f.port_path) * ".f"
Base.string(e::EVar) = string(e.box_path * e.port_path) * ".e"


SymbolicExpressions.ast(x::PortVar) = Symbol(replace(string(x), '.' => '₊'))


XVar(port_name::Symbol) = XVar(DtryPath(), DtryPath(port_name))
FVar(port_name::Symbol) = FVar(DtryPath(), DtryPath(port_name))
EVar(port_name::Symbol) = EVar(DtryPath(), DtryPath(port_name))

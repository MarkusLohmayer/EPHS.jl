
"""
    Par(box_path::DtryPath, par_path::DtryPath, value::Float64

Symbolic parameter identified by `box_path * par_path`.

# Fields
- `box_path`: indicates the subsystem to which the parameter belongs
- `par_path`: distinguishes between different parameters of the same subsystem
- `value`: (default) value of the parameter
"""
struct Par <: SymVar
  box_path::DtryPath
  par_path::DtryPath
  value::Float64
end


"""
    Par(name::Symbol, value::Float64

Constructs a symbolic [`Par`](@ref)ameter with
`box_path=DtryPath()` and `par_path=DtryPath(name)`.

# Arguments
- `name`: name of the parameter
- `value`: (default) value of the parameter
"""
Par(name::Symbol, value::Float64) = Par(DtryPath(), DtryPath(name), value)


Base.string(par::Par) = string(par.box_path * par.par_path)


SymbolicExpressions.ast(par::Par) = par.value

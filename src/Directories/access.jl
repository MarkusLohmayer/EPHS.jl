"""
Abstract supertype for exceptions
that may be thrown when accessing directories.
Concrete subtypes are
[`DtryBranchError`](@ref) (branch with a given name does not exist) and
[`DtryLeafError`](@ref) (given directory is not a leaf).
"""
abstract type DtryAccessError <: Exception end


"""
    DtryBranchError(dtry::AbstractDtry, name::Symbol)

The given directory has no direct subdirectory with the given name.
"""
struct DtryBranchError <: DtryAccessError
  dtry::AbstractDtry
  name::Symbol
end


function Base.showerror(io::IO, e::DtryBranchError)
  print(io, "DtryBranchError: No branch named ", e.name)
end


"""
    DtryLeafError(dtry::AbstractDtry)

The given directory is not a leaf holding a value.
"""
struct DtryLeafError <: DtryAccessError
  dtry::AbstractDtry
end


function Base.showerror(io::IO, ::DtryLeafError)
  print(io, "DtryLeafError: Tried to access value, but directory is not a leaf")
end


function Base.getproperty(dtry::NonEmptyDtry, name::Symbol)
  if leaf_or_node(dtry) isa DtryNode
    node = leaf_or_node(dtry)
    if haskey(node.branches, name)
      return node.branches[name]
    end
  end
  throw(DtryBranchError(dtry, name))
end


function Base.getproperty(dtry::Dtry, name::Symbol)
  if !isempty(dtry)
    nonempty = nothing_or_nonempty(dtry)
    return getproperty(nonempty, name)
  end
  throw(DtryBranchError(dtry, name))
end


function Base.hasproperty(dtry::NonEmptyDtry, name::Symbol)
  if leaf_or_node(dtry) isa DtryNode
    node = leaf_or_node(dtry)
    if haskey(node.branches, name)
      return true
    end
  end
  false
end


function Base.hasproperty(dtry::Dtry, name::Symbol)
  if !isempty(dtry)
    nonempty = nothing_or_nonempty(dtry)
    return hasproperty(nonempty, name)
  end
  false
end


function Base.propertynames(dtry::NonEmptyDtry)
  if leaf_or_node(dtry) isa DtryNode
    node = leaf_or_node(dtry)
    keys(node.branches)
  else
    Symbol[]
  end
end


function Base.propertynames(dtry::Dtry)
  if !isempty(dtry)
    nonempty = nothing_or_nonempty(dtry)
    return propertynames(nonempty)
  else
    Symbol[]
  end
end


"""
    getindex(dtry::NonEmptyDtry{T}) -> T

If `dtry` isa leaf, `dtry[]` returns its value.
Otherwise, throws a [`DtryLeafError`](@ref)
"""
function Base.getindex(dtry::NonEmptyDtry{T})::T where {T}
  if leaf_or_node(dtry) isa DtryLeaf
    leaf = leaf_or_node(dtry)
    return leaf.value
  end
  throw(DtryLeafError(dtry))
end


"""
    getindex(dtry::Dtry{T}) -> T

If `dtry` isa leaf, `dtry[]` returns its value.
Otherwise, throws a [`DtryLeafError`](@ref)
"""
function Base.getindex(dtry::Dtry{T})::T where {T}
  if !isempty(dtry)
    nonempty = nothing_or_nonempty(dtry)
    return getindex(nonempty)
  end
  throw(DtryLeafError(dtry))
end

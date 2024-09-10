
abstract type DtryAccessError <: Exception end


struct DtryBranchError <: DtryAccessError
  dtry::AbstractDtry
  name::Symbol
end


function Base.showerror(io::IO, e::DtryBranchError)
  print(io, "DtryBranchError: No branch named ", e.name)
end


struct DtryLeafError <: DtryAccessError
  dtry::AbstractDtry
end


function Base.showerror(io::IO, e::DtryLeafError)
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


function Base.getindex(dtry::NonEmptyDtry{T})::T where {T}
  if leaf_or_node(dtry) isa DtryLeaf
    leaf = leaf_or_node(dtry)
    return leaf.value
  end
  throw(DtryLeafError(dtry))
end


function Base.getindex(dtry::Dtry{T})::T where {T}
  if !isempty(dtry)
    nonempty = nothing_or_nonempty(dtry)
    return getindex(nonempty)
  end
  throw(DtryLeafError(dtry))
end

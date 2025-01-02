
"Linked list of symbols represening a directory path"
struct DtryPath
  nothing_or_link::Union{
    Nothing,
    Tuple{Symbol,DtryPath}
  }
end


"Path representing the root directory"
const ■ = DtryPath(nothing)


function DtryPath(symbols::Vararg{Symbol})
  path = ■
  for i in length(symbols):-1:1
    path = DtryPath((symbols[i], path))
  end
  path
end


nothing_or_link(p::DtryPath) = getfield(p, :nothing_or_link)


Base.propertynames(::DtryPath) = Symbol[]


Base.isempty(p::DtryPath) = isnothing(nothing_or_link(p))


function Base.getproperty(path::DtryPath, name::Symbol)
  if isempty(path)
    DtryPath((name, path))
  else
    link = nothing_or_link(path)
    prev_name, prev_path = link
    # reverse list (top-down order)
    DtryPath((prev_name, getproperty(prev_path, name)))
  end
end


function Base.:(*)(p1::DtryPath, p2::DtryPath)
  if isempty(p1)
    p2
  else
    link = nothing_or_link(p1)
    prev_name, prev_path = link
    DtryPath((prev_name, prev_path * p2))
  end
end


function Base.length(path::DtryPath)
  len = 0
  while !isempty(path)
    len += 1
    _, path = nothing_or_link(path)
  end
  len
end


function Base.iterate(path::DtryPath, state=nothing)
  if isnothing(state) # initialize state to start iteration
    state = path
  end
  if isempty(state) # end of list
    return nothing
  else # iterate
    return nothing_or_link(state)
  end
end


Base.string(path::DtryPath) = join(path, '.')


function Base.show(io::IO, path::DtryPath)
  if isempty(path)
    print(io, "■")
  else
    print(io, "■.")
    join(io, path, '.')
  end
end


# function Base.Symbol(path::DtryPath)
#   if !isempty(path)
#     link = nothing_or_link(path)
#     name, rest = link
#     if rest == DtryPath()
#       return name
#     end
#   end
#   error("The given path $(string(path)) does not consist of a single name")
# end


# Access directories using a path

function Base.getindex(dtry::NonEmptyDtry, path::DtryPath)
  if isempty(path)
    if leaf_or_node(dtry) isa DtryLeaf
      leaf = leaf_or_node(dtry)
      return leaf.value
    end
    throw(DtryLeafError(dtry))
  else
    link = nothing_or_link(path)
    name, path = link
    return getproperty(dtry, name)[path]
  end
end


function Base.getindex(dtry::Dtry, path::DtryPath)
  if !isempty(dtry)
    nonempty = nothing_or_nonempty(dtry)
    return getindex(nonempty, path)
  end
  if isempty(path)
    throw(DtryLeafError(dtry))
  else
    link = nothing_or_link(path)
    name, _ = link
    throw(DtryBranchError(dtry, name))
  end
end


function Base.haskey(dtry::NonEmptyDtry, path::DtryPath)
  if isempty(path)
    if leaf_or_node(dtry) isa DtryLeaf
      return true
    end
  else
    link = nothing_or_link(path)
    name, path = link
    if hasproperty(dtry, name) && haskey(getproperty(dtry, name), path)
      return true
    end
  end
  false
end


function Base.haskey(dtry::Dtry, path::DtryPath)
  if isempty(dtry)
    return false
  else
    nonempty = nothing_or_nonempty(dtry)
    return haskey(nonempty, path)
  end
end


function Base.get(dtry::NonEmptyDtry, path::DtryPath, default)
  if isempty(path)
    if leaf_or_node(dtry) isa DtryLeaf
      leaf = leaf_or_node(dtry)
      return leaf.value
    end
    return default
  else
    link = nothing_or_link(path)
    name, path = link
    if hasproperty(dtry, name)
      return getproperty(dtry, name)[path]
    end
    return default
  end
end


function Base.get(dtry::Dtry, path::DtryPath, default)
  if !isempty(dtry)
    nonempty = nothing_or_nonempty(dtry)
    return get(nonempty, path, default)
  end
  return default
end

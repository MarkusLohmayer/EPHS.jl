
"""
A `DtryPath` is a linked list of `Symbol`s
representing a path in a directory,
see also [`■`](@ref).
"""
struct DtryPath
  nothing_or_link::Union{
    Nothing,
    Tuple{Symbol,DtryPath}
  }
end


"""
[`DtryPath`](@ref) representing
the root node of a directory.
With that, `■.foo` represents
the path to a subdirectory named `foo`.
"""
const ■ = DtryPath(nothing)


"""
    DtryPath(names::Vararg{Symbol})

Construct a `DtryPath` from a series of names.

# Example
```jldoctest
julia> DtryPath(:foo, :bar) == ■.foo.bar
true
```
"""
function DtryPath(names::Vararg{Symbol})
  path = ■
  for i in length(names):-1:1
    path = DtryPath((names[i], path))
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


"""
    *(p1::DtryPath, p2::DtryPath) -> DtryPath

Concatenate two [`DtryPath`](@ref)s.

# Example
```jldoctest
julia> ■.foo * ■.bar == ■.foo.bar
true
```
"""
function Base.:(*)(p1::DtryPath, p2::DtryPath)
  if isempty(p1)
    p2
  else
    link = nothing_or_link(p1)
    prev_name, prev_path = link
    DtryPath((prev_name, prev_path * p2))
  end
end


"""
    length(path::DtryPath) -> Int

Returns the length of the [`DtryPath`](@ref) (linked list of `Symbols`).

# Example
```jldoctest
julia> length(■.foo.bar) == 2
true
```
"""
function Base.length(path::DtryPath)::Int
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


# Access directories using a path

"""
    getindex(dtry::NonEmptyDtry{T}, path::DtryPath) -> T

If `path` refers to a value within `dtry`, returns the value.
Otherwise, throws a [`DtryAccessError`](@ref).
"""
function Base.getindex(dtry::NonEmptyDtry{T}, path::DtryPath)::T where {T}
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


"""
    getindex(dtry::Dtry{T}, path::DtryPath) -> T

If `path` refers to a value within `dtry`, returns the value.
Otherwise, throws a [`DtryAccessError`](@ref).
"""
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


"""
    hasprefix(dtry::NonEmptyDtry, prefix::DtryPath) -> Bool

Returns `true` if the given directory has a (complete) path (to a leaf/value),
which starts with the given prefix (or incomplete path).
"""
function hasprefix(dtry::NonEmptyDtry, prefix::DtryPath)::Bool
  if isempty(prefix)
    return true
  else
    link = nothing_or_link(prefix)
    name, prefix = link
    return hasproperty(dtry, name) && hasprefix(getproperty(dtry, name), prefix)
  end
end


"""
    hasprefix(dtry::Dtry, prefix::DtryPath) -> Bool

Returns `true` if the given directory has a (complete) path (to a leaf/value),
which starts with the given prefix (or incomplete path).
"""
function hasprefix(dtry::Dtry, prefix::DtryPath)::Bool
  if isempty(dtry)
    return false
  else
    nonempty = nothing_or_nonempty(dtry)
    return hasprefix(nonempty, prefix)
  end
end


"""
    haspath(dtry::NonEmptyDtry, path::DtryPath) -> Bool

Returns `true` if the given directory contains
a leaf/value at the given path.
"""
function haspath(dtry::NonEmptyDtry, path::DtryPath)
  if isempty(path)
    return leaf_or_node(dtry) isa DtryLeaf
  else
    link = nothing_or_link(path)
    name, path = link
    return hasproperty(dtry, name) && haspath(getproperty(dtry, name), path)
  end
end


"""
    haspath(dtry::Dtry, path::DtryPath) -> Bool

Returns `true` if the given directory contains
a leaf/value at the given path.
"""
function haspath(dtry::Dtry, path::DtryPath)::Bool
  if isempty(dtry)
    return false
  else
    nonempty = nothing_or_nonempty(dtry)
    return haspath(nonempty, path)
  end
end


"""
    get(dtry::NonEmptyDtry, path::DtryPath, default)

If `path` refers to a value within `dtry`, returns the value.
Otherwise, returns `default`.
"""
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
      sub_dtry = getproperty(dtry, name)
      return get(sub_dtry, path, default)
    end
    return default
  end
end


"""
    get(dtry::Dtry, path::DtryPath, default)

If `path` refers to a value within `dtry`, returns the value.
Otherwise, returns `default`.
"""
function Base.get(dtry::Dtry, path::DtryPath, default)
  if !isempty(dtry)
    nonempty = nothing_or_nonempty(dtry)
    return get(nonempty, path, default)
  end
  return default
end

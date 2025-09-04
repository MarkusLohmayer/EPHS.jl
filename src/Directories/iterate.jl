
"""
    foreach(f, dtry::NonEmptyDtry{T}) -> Nothing

Call function `f` on each `Pair{DtryPath,T}`.
"""
function Base.foreach(f, dtry::NonEmptyDtry; prefix=■)
  if leaf_or_node(dtry) isa DtryLeaf
    leaf = leaf_or_node(dtry)
    f(prefix => leaf.value)
  else
    node = leaf_or_node(dtry)
    for (name, branch) in node.branches
      foreach(f, branch; prefix=getproperty(prefix, name))
    end
  end
  nothing
end


"""
    foreach(f, dtry::Dtry{T}) -> Nothing

Call function `f` on each `Pair{DtryPath,T}`.
"""
function Base.foreach(f, dtry::Dtry)
  if !isempty(dtry)
    nonempty = nothing_or_nonempty(dtry)
    return foreach(f, nonempty)
  end
  nothing
end


"""
    foreachpath(f, dtry::NonEmptyDtry) -> Nothing

Call function `f` on each `path::DtryPath`.
"""
function foreachpath(f, dtry::NonEmptyDtry; prefix=■)
  if leaf_or_node(dtry) isa DtryLeaf
    f(prefix)
  else
    node = leaf_or_node(dtry)
    for (name, branch) in node.branches
      foreachpath(f, branch; prefix=getproperty(prefix, name))
    end
  end
  nothing
end


"""
    foreachpath(f, dtry::Dtry) -> Nothing

Call function `f` on each `path::DtryPath`.
"""
function foreachpath(f, dtry::Dtry)
  if !isempty(dtry)
    nonempty = nothing_or_nonempty(dtry)
    return foreachpath(f, nonempty)
  end
  nothing
end


"""
    foreachvalue(f, dtry::NonEmptyDtry{T}) -> Nothing

Call function `f` on each `value::T`.
"""
function foreachvalue(f, dtry::NonEmptyDtry)
  if leaf_or_node(dtry) isa DtryLeaf
    leaf = leaf_or_node(dtry)
    f(leaf.value)
  else
    node = leaf_or_node(dtry)
    for branch in values(node.branches)
      foreachvalue(f, branch)
    end
  end
  nothing
end


"""
    foreachvalue(f, dtry::Dtry{T}) -> Nothing

Call function `f` on each `value::T`.
"""
function foreachvalue(f, dtry::Dtry)
  if !isempty(dtry)
    nonempty = nothing_or_nonempty(dtry)
    return foreachvalue(f, nonempty)
  end
  nothing
end


function Base.foreach(f, dtry1::NonEmptyDtry, dtry2::NonEmptyDtry; prefix=■)
  if leaf_or_node(dtry1) isa DtryLeaf && leaf_or_node(dtry2) isa DtryLeaf
    leaf1 = leaf_or_node(dtry1)
    leaf2 = leaf_or_node(dtry2)
    f((prefix, leaf1.value, leaf2.value))
    return nothing
  elseif leaf_or_node(dtry1) isa DtryNode && leaf_or_node(dtry2) isa DtryNode
    node1 = leaf_or_node(dtry1)
    node2 = leaf_or_node(dtry2)
    if keys(node1.branches) == keys(node2.branches)
      for ((name, child1), (_, child2)) in zip(node1.branches, node2.branches)
        foreach(f, child1, child2; prefix=getproperty(prefix, name))
      end
      return nothing
    end
  end
  error("the two directories do not have the same tree structure")
end


function Base.foreach(f, dtry1::Dtry, dtry2::Dtry)
  if !isempty(dtry1) && !isempty(dtry2)
    nonempty1 = nothing_or_nonempty(dtry1)
    nonempty2 = nothing_or_nonempty(dtry2)
    return foreach(f, nonempty1, nonempty2)
  end
  if isempty(dtry1) || isempty(dtry2)
    error("the two directories do not have the same tree structure")
  end
  nothing
end


# Probably not needed since we don't define `iterate`
Base.valtype(::AbstractDtry{T}) where {T} = T
Base.valtype(::Type{<:AbstractDtry{T}}) where {T} = T
# `eltype` should probably be `Pair{Symbol,T}`
Base.eltype(::AbstractDtry{T}) where {T} = T
Base.eltype(::Type{<:AbstractDtry{T}}) where {T} = T



# (why so) slow:
# function Base.values(dtry::NonEmptyDtry{T}) where {T}
#   if leaf_or_node(dtry) isa DtryLeaf
#     leaf = leaf_or_node(dtry)
#     return (leaf.value for _ in 1:1)
#   else
#     node = leaf_or_node(dtry)
#     return Iterators.flatten(values(branch) for branch in values(node.branches))
#   end
# end


# function Base.values(dtry::Dtry{T}) where {T}
#   if isempty(dtry)
#     ()
#   else
#     nonempty = nothing_or_nonempty(dtry)
#     values(nonempty)
#   end
# end


"""
    all(p, dtry::NonEmptyDtry{T}) -> Bool

Returns `true` if predicate `p : T -> Bool` returns `true`
for all values of the directory.
"""
function Base.all(p, dtry::NonEmptyDtry)
  if leaf_or_node(dtry) isa DtryLeaf
    leaf = leaf_or_node(dtry)
    return p(leaf.value)
  else
    node = leaf_or_node(dtry)
    for branch in values(node.branches)
      all(p, branch) || return false
    end
    return true
  end
end


"""
    all(p, dtry::Dtry{T}) -> Bool

Returns `true` if predicate `p : T -> Bool` returns `true`
for all values of the directory.
"""
function Base.all(p, dtry::Dtry)
  if isempty(dtry)
    return true
  else
    nonempty = nothing_or_nonempty(dtry)
    return all(p, nonempty)
  end
end


"""
    collect(dtry::AbstractDtry{T}) -> Vector{T}

Collect values from a directory.
"""
function Base.collect(dtry::AbstractDtry{T}) where {T}
  xs = Vector{T}()
  foreachvalue(dtry) do val
    push!(xs, val)
  end
  xs
end

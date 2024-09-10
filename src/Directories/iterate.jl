
"""
    foreach(f, dtry::NonEmptyDtry{T}) where {T} -> Nothing

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
    foreach(f, dtry::Dtry{T}) where {T} -> Nothing

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
    foreachpath(f, dtry::NonEmptyDtry{T}) where {T} -> Nothing

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
    foreachpath(f, dtry::Dtry{T}) where {T} -> Nothing

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
    foreachvalue(f, dtry::NonEmptyDtry{T}) where {T} -> Nothing

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
    foreachvalue(f, dtry::Dtry{T}) where {T} -> Nothing

Call function `f` on each `value::T`.
"""
function foreachvalue(f, dtry::Dtry)
  if !isempty(dtry)
    nonempty = nothing_or_nonempty(dtry)
    return foreachvalue(f, nonempty)
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

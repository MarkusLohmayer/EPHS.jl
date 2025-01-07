
isleaf(dtry::AbstractDtry) =
  !isempty(dtry) && leaf_or_node(nothing_or_nonempty(dtry)) isa DtryLeaf


"""
    merge(dtry1::NonEmptyDtry{T}, dtry2::NonEmptyDtry{T}) -> NonEmptyDtry{T}
    merge(dtry1::Dtry{T}, dtry2::Dtry{T}) -> Dtry{T}

Merge two directories,
given that their namespaces are disjoint,
i.e. the union of their namespaces is prefix-free.
"""
function Base.merge(dtry1::T, dtry2::T) where {T<:AbstractDtry}
  if isleaf(dtry1) || isleaf(dtry2)
    error("merge conflict: the directories do not have disjoint namespaces")
  end
  isempty(dtry1) && return dtry2
  isempty(dtry2) && return dtry1
  node1 = leaf_or_node(nothing_or_nonempty(dtry1))
  node2 = leaf_or_node(nothing_or_nonempty(dtry2))
  merged_pairs = Vector{Pair{Symbol,<:AbstractDtry}}()
  for (name, child) in node1.branches
    if haskey(node2.branches, name)
      push!(merged_pairs, name => merge(child, node2.branches[name]))
    else
      push!(merged_pairs, name => child)
    end
  end
  for (name, child) in node2.branches
    if !haskey(node1.branches, name)
      push!(merged_pairs, name => child)
    end
  end
  T(merged_pairs...)
end


"""
    flatten(dtry::NonEmptyDtry{NonEmptyDtry{T}}) -> Dtry{T}
Flattens a nonempty directory of nonempty directories (monad multiplication).
"""
function flatten(dtry::NonEmptyDtry{NonEmptyDtry{T}}) where  {T}
  if leaf_or_node(dtry) isa DtryLeaf
    leaf = leaf_or_node(dtry)
    leaf.value
  else
    node = leaf_or_node(dtry)
    NonEmptyDtry{T}((name => flatten(child) for (name, child) in node.branches)...)
  end
end


"""
    flatten(dtry::Dtry{<:Dtry{T}}) -> Dtry{T}
Flattens a directory of directories (monad multiplication).
"""
function flatten(dtry::AbstractDtry{Dtry{T}}) where {T}
  isempty(dtry) && return Dtry{T}()
  nonempty = dtry isa NonEmptyDtry ? dtry : nothing_or_nonempty(dtry)
  if leaf_or_node(nonempty) isa DtryLeaf
    leaf = leaf_or_node(nonempty)
    leaf.value
  else
    node = leaf_or_node(nonempty)
    Dtry{T}((name => flatten(child) for (name, child) in node.branches)...)
  end
end

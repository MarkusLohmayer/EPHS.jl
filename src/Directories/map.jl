# Functions for mapping over and filtering directories

"""
    map(f, dtry::NonEmptyDtry{T}, X::Type) -> NonEmptyDtry{X}

Make a new nonempty directory of `X`s with the same tree structure as `dtry`,
where the value at path `p` is given by `f(dtry[p])::X`.
"""
function Base.map(f, dtry::NonEmptyDtry{T}, X::Type) where {T}
  if leaf_or_node(dtry) isa DtryLeaf
    leaf = leaf_or_node(dtry)
    old_value::T = leaf.value
    new_value::X = f(old_value)
    NonEmptyDtry{X}(new_value)
  else
    node = leaf_or_node(dtry)
    NonEmptyDtry{X}((name => map(f, child, X) for (name, child) in node.branches)...)
  end
end


"""
    map(f, dtry::Dtry{T}, X::Type) -> Dtry{X}

Make a new directory of `X`s with the same tree structure as `dtry`,
where the value at path `p` is given by `f(dtry[p])::X`.
"""
function Base.map(f, dtry::Dtry{T}, X::Type) where {T}
  isempty(dtry) && return Dtry{X}()
  nonempty = nothing_or_nonempty(dtry)
  if leaf_or_node(nonempty) isa DtryLeaf
    leaf = leaf_or_node(nonempty)
    old_value::T = leaf.value
    new_value::X = f(old_value)
    Dtry{X}(new_value)
  else
    node = leaf_or_node(nonempty)
    Dtry{X}((name => map(f, child, X) for (name, child) in node.branches)...)
  end
end


"""
    map(f, dtry::AbstractDtry)

Map over a directory, trying to infer the return type of `f`.
"""
function Base.map(f, dtry::AbstractDtry{T}) where {T}
  X = Core.Compiler.return_type(f, Tuple{T})
  map(f, dtry, X)
end


"""
    mapwithpath(f, dtry::Dtry{T}, X::Type) -> Dtry{X}

Make a new directory of `X`s with the same tree structure as `dtry`,
where the value at path `p` is given by `f((p, dtry[p]))::X`.
"""
function mapwithpath(f, dtry::AbstractDtry{T}, X::Type; prefix=■) where {T}
  isempty(dtry) && return Dtry{X}()
  nonempty = nothing_or_nonempty(dtry)
  if leaf_or_node(nonempty) isa DtryLeaf
    leaf = leaf_or_node(nonempty)
    old_value::T = leaf.value
    new_value::X = f(prefix, old_value)
    Dtry{X}(new_value)
  else
    node = leaf_or_node(nonempty)
    Dtry{X}((
      name => mapwithpath(f, child, X; prefix=getproperty(prefix, name))
      for (name, child) in node.branches
    )...)
  end
end


"""
    zipmap(f, dtry1::NonEmptyDtry{T1}, dtry2::NonEmptyDtry{T2}, X::Type) -> NonEmptyDtry{X}

Given a nonempty directory of `T1`s and a nonempty directory of `T2`s
with the same tree sturcture, as well as a function `f : T1 × T2 -> X`,
produce a new nonempty directory of `X`s,
where the value at path `p` is given by `f(dtry1[p], dtry2[p])`.
"""
function zipmap(f, dtry1::NonEmptyDtry{T1}, dtry2::NonEmptyDtry{T2}, X::Type) where {T1,T2}
  if leaf_or_node(dtry1) isa DtryLeaf && leaf_or_node(dtry2) isa DtryLeaf
    leaf1 = leaf_or_node(dtry1)
    leaf2 = leaf_or_node(dtry2)
    old_value1::T1 = leaf1.value
    old_value2::T2 = leaf2.value
    new_value::X = f(old_value1, old_value2)
    return NonEmptyDtry{X}(new_value)
  else
    node1 = leaf_or_node(dtry1)
    node2 = leaf_or_node(dtry2)
    if keys(node1.branches) == keys(node2.branches)
      return NonEmptyDtry{X}((
        name => zipmap(f, child1, child2, X)
        for ((name, child1), (_, child2)) in zip(node1.branches, node2.branches)
      )...)
    end
  end
  error("the two directories have not the same tree structure")
end


"""
    zipmap(f, dtry1::Dtry{T1}, dtry2::Dtry{T2}, X::Type) -> Dtry{X}

Given a directory of `T1`s and a directory of `T2`s with the same tree sturcture,
as well as a function `f : T1 × T2 -> X`,
produce a new directory of `X`s,
where the value at path `p` is given by `f(dtry1[p], dtry2[p])`.
"""
function zipmap(f, dtry1::Dtry{T1}, dtry2::Dtry{T2}, X::Type) where {T1,T2}
  isempty(dtry1) && isempty(dtry2) && return Dtry{X}()
  nonempty1 = nothing_or_nonempty(dtry1)
  nonempty2 = nothing_or_nonempty(dtry2)
  if leaf_or_node(nonempty1) isa DtryLeaf && leaf_or_node(nonempty2) isa DtryLeaf
    leaf1 = leaf_or_node(nonempty1)
    leaf2 = leaf_or_node(nonempty2)
    old_value1::T1 = leaf1.value
    old_value2::T2 = leaf2.value
    new_value::X = f(old_value1, old_value2)
    return Dtry{X}(new_value)
  else
    node1 = leaf_or_node(nonempty1)
    node2 = leaf_or_node(nonempty2)
    if keys(node1.branches) == keys(node2.branches)
      return Dtry{X}((
        name => zipmap(f, child1, child2, X)
        for ((name, child1), (_, child2)) in zip(node1.branches, node2.branches)
      )...)
    end
  end
  error("the two directories have not the same tree structure")
end


Base.zip(dtry1::AbstractDtry{T1}, dtry2::AbstractDtry{T2}) where {T1,T2} =
  zipmap((a, b) -> (a, b), dtry1, dtry2, Tuple{T1,T2})


"""
    zipmapwithpath(f, dtry1::Dtry{T1}, dtry2::Dtry{T2}, X::Type) -> Dtry{X}

Given a directory of `T1`s and a directory of `T2`s with the same tree sturcture,
as well as a function `f : DtryPath × T1 × T2 -> X`,
produce a new directory of `X`s,
where the value at path `p` is given by `f(p, dtry1[p], dtry2[p])`.
"""
function zipmapwithpath(f, dtry1::AbstractDtry{T1}, dtry2::AbstractDtry{T2}, X::Type; prefix=■) where {T1,T2}
  isempty(dtry1) && isempty(dtry2) && return Dtry{X}()
  nonempty1 = nothing_or_nonempty(dtry1)
  nonempty2 = nothing_or_nonempty(dtry2)
  if leaf_or_node(nonempty1) isa DtryLeaf && leaf_or_node(nonempty2) isa DtryLeaf
    leaf1 = leaf_or_node(nonempty1)
    leaf2 = leaf_or_node(nonempty2)
    old_value1::T1 = leaf1.value
    old_value2::T2 = leaf2.value
    new_value::X = f(prefix, old_value1, old_value2)
    return Dtry{X}(new_value)
  else
    node1 = leaf_or_node(nonempty1)
    node2 = leaf_or_node(nonempty2)
    if keys(node1.branches) == keys(node2.branches)
      return Dtry{X}((
        name => zipmapwithpath(f, child1, child2, X; prefix=getproperty(prefix, name))
        for ((name, child1), (_, child2)) in zip(node1.branches, node2.branches)
      )...)
    end
  end
  error("the two directories have not the same tree structure")
end


"""
    filtermap(f, dtry::AbstractDtry{T}, X::Type) -> Dtry{X}

Make a new directory of `X`s from a (nonempty) directory of `T`s
based on a function `f : T -> Union{Some{X},Nothing}`.
When `f` returns `nothing`, the respective entry is filtered out.
"""
function filtermap(f, dtry::AbstractDtry{T}, X::Type) where {T}
  isempty(dtry) && return Dtry{X}()
  nonempty = nothing_or_nonempty(dtry)
  if leaf_or_node(nonempty) isa DtryLeaf
    leaf = leaf_or_node(nonempty)
    old_value::T = leaf.value
    res = f(old_value)
    isnothing(res) ? Dtry{X}() : Dtry{X}(res.value)
  else
    node = leaf_or_node(nonempty)
    Dtry{X}((name => filtermap(f, child, X) for (name, child) in node.branches)...)
  end
end


"""
    filter(f, dtry::AbstractDtry{T}) -> Dtry{T}

Given a function `f : T -> Bool` and
a (nonempty) directory of `T`s,
produce a new directory of `T`s
by keeping the entry at path `p` only if `f(dtry[p]) == true`.
"""
function Base.filter(f, dtry::AbstractDtry{T}) where {T}
  isempty(dtry) && return dtry
  nonempty = nothing_or_nonempty(dtry)
  if leaf_or_node(nonempty) isa DtryLeaf
    leaf = leaf_or_node(nonempty)
    f(leaf.value) ? dtry : Dtry{T}()
  else
    node = leaf_or_node(nonempty)
    Dtry{T}((name => filter(f, child) for (name, child) in node.branches)...)
  end
end


# # Try to improve performance
# function Base.mapreduce(f, op, dtry::NonEmptyDtry)
#   if leaf_or_node(dtry) isa DtryLeaf
#     leaf = leaf_or_node(dtry)
#     return f(leaf.value)
#   else
#     node = leaf_or_node(dtry)
#     itr = (mapreduce(f, op, branch) for branch in values(node.branches))
#     return reduce(op, itr)
#   end
# end


# function Base.mapreduce(f, op, dtry::Dtry, init)
#   if isempty(dtry)
#     return init
#   else
#     nonempty = nothing_or_nonempty(dtry)
#     return mapreduce(f, op, nonempty)
#   end
# end

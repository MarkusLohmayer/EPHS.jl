
Base.show(io::IO, ::MIME"text/plain", dtry::AbstractDtry) = print_dtry(io, dtry)


function print_dtry(io::IO, dtry::Dtry)
  if isempty(dtry)
    println(io, "■")
  else
    nonempty = nothing_or_nonempty(dtry)
    print_dtry(io, nonempty)
  end
end


function print_dtry(io::IO, dtry::NonEmptyDtry)
  if leaf_or_node(dtry) isa DtryLeaf
    leaf = leaf_or_node(dtry)
    println(io, "■ => ", string(leaf.value))
  else
    node = leaf_or_node(dtry)
    println(io, "■")
    _print_dtry(io, node, "")
  end
end


function _print_dtry(io::IO, node::DtryNode, prefix::String)
  names, children = keys(node.branches), values(node.branches)
  n = length(names)
  for i in 1:n
    islast = i == n
    branch_prefix = islast ? "└─ " : "├─ "
    child = leaf_or_node(children[i])
    if child isa DtryLeaf
      println(io, prefix * branch_prefix * string(names[i]) * " => " * string(child.value))
    else
      println(io, prefix * branch_prefix * string(names[i]))
      _print_dtry(io, child, prefix * (islast ? "   " : "│  "))
    end
  end
end

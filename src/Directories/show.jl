
Base.show(io::IO, ::MIME"text/plain", dtry::AbstractDtry) = print_dtry(io, dtry)


function print_dtry(
  io::IO,
  dtry::Dtry;
  prefix::String="",
  print_value::Union{Nothing,Function}=nothing
)
  if isempty(dtry)
    print(io, "■")
  else
    nonempty = nothing_or_nonempty(dtry)
    print_dtry(io, nonempty; prefix, print_value)
  end
end


function print_dtry(
  io::IO,
  dtry::NonEmptyDtry;
  prefix::String="",
  print_value::Union{Nothing,Function}=nothing
)
  if leaf_or_node(dtry) isa DtryLeaf
    leaf = leaf_or_node(dtry)
    print(io, "■ => ")
    if isnothing(print_value)
      show(io, leaf.value)
    else
      # `prefix::String` argument is relevant only if output of `print_value` has multiple lines
      print_value(io, leaf.value, prefix * "     ")
    end
  else
    node = leaf_or_node(dtry)
    print(io, "■")
    _print_dtry(io, node, prefix, print_value)
  end
end


function _print_dtry(
  io::IO,
  node::DtryNode,
  prefix::String,
  print_value::Union{Nothing,Function}=nothing
)
  names, children = keys(node.branches), values(node.branches)
  n = length(names)
  for i in 1:n
    islast = i == n
    branch_prefix = islast ? "└─ " : "├─ "
    name = string(names[i])
    child = leaf_or_node(children[i])
    println(io)
    if child isa DtryLeaf
      print(io, prefix * branch_prefix * name * " => ")
      if isnothing(print_value)
        show(io, child.value)
      else
        print_value(io, child.value, prefix * (islast ? "   " : "│  ") * repeat(" ", length(name) + 4))
      end
    else
      print(io, prefix * branch_prefix * name)
      _print_dtry(io, child, prefix * (islast ? "   " : "│  "), print_value)
    end
  end
end


Base.show(io::IO, ::MIME"text/plain", dtry::AbstractDtry) = print_dtry(io, dtry)


"""
    print_dtry(io::IO, dtry::Dtry{T}; prefix::String, print_value=nothing)

Write a pretty-printed representation of the given directory to `io`.
As an optional keyword argument,
a function `print_value(io::IO, value::T, prefix::String)`
can be used to pretty-print the values.
Whenever the output of `print_value` spans more than one line,
`prefix` is prepended to the extra lines.
To print a directory of directories, let `print_values=print_dtry`.
"""
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


Base.show(io::IO, dtry::AbstractDtry) = print_dtry_repr(io, dtry)


"""
    print_dtry_repr(io::IO, dtry::Dtry{T})

Write a round-trippable code representation of the given directory to `io`.
"""
function print_dtry_repr(
  io::IO,
  dtry::Dtry{T};
  prefix::String=""
) where {T}
  if isempty(dtry)
    print(io, "Dtry{$T}()")
  else
    nonempty = nothing_or_nonempty(dtry)
    print_dtry_repr(io, nonempty; prefix)
  end
end


function print_dtry_repr(
  io::IO,
  dtry::NonEmptyDtry{T};
  prefix::String=""
) where {T}
  _print_dtry_repr(io, leaf_or_node(dtry), prefix)
end


function _print_dtry_repr(
  io::IO,
  leaf::DtryLeaf{T},
  _::String
) where {T}
    if typeof(leaf.value) === T
      print(io, "Dtry(")
    else
      print(io, "Dtry{$T}(")
    end
    show(io, leaf.value)
    print(io, ")")
end


function _print_dtry_repr(
  io::IO,
  node::DtryNode,
  prefix::String
)
  print(io, "Dtry(")
  n = length(node.branches)
  for (i, (name, child)) in enumerate(pairs(node.branches))
    print(io, "\n", prefix, "  ")
    show(io, name)
    print(io, " => ")
    _print_dtry_repr(io, leaf_or_node(child), prefix * "  ")
    if i < n
      print(io, ",")
    end
  end
  print(io, "\n", prefix, ")")
end

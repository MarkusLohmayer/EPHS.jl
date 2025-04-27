
"""
    replace(f, expr::SymExpr, T::Type{<:SymExpr}) -> SymExpr

Transforms a [`SymExpr`](@ref) using a function
`f : T -> SymExpr`, where `T <: SymExpr`.
Goes from the root into the expression tree
and whenever a `node::T` is encountered,
it is replaced by the new node `f(node)`.
"""
function Base.replace(f::Function, expr::SymExpr, T::Type{<:SymExpr})::SymExpr
  if expr isa T
    return f(expr)
  elseif expr isa SymOp
    # by default, the transform is applied to all arguments of an operation
    args = map(name -> getfield(expr, name), fieldnames(typeof(expr)))
    transformed_args = map(args) do argument
      if argument isa SymExpr # for operations with fixed arity
        return replace(f, argument, T)
      elseif argument isa Tuple{Vararg{SymExpr}}  # for n-ary operations like Add
        return map(argument) do tuple_element
          replace(f, tuple_element, T)
        end
      else
        error("should not reach here")
      end
    end
    return typeof(expr)(transformed_args...)
  else
    # identity as fallback case
    return expr
  end
end


"""
    foreach(f, expr::SymExpr, T::Type{<:SymExpr}) -> nothing

Goes from the root into the expression tree
and whenever a `node::T` is encountered, calls `f(node)`.
"""
function Base.foreach(f::Function, expr::SymExpr, T::Type{<:SymExpr})
  if expr isa T
    f(expr)
  elseif expr isa SymOp
    args = map(name -> getfield(expr, name), fieldnames(typeof(expr)))
    foreach(args) do argument
      if argument isa SymExpr
        foreach(f, argument, T)
      elseif argument isa Tuple{Vararg{SymExpr}}
        foreach(argument) do tuple_element
          foreach(f, tuple_element, T)
        end
      else
        error("should not reach here")
      end
    end
  end
  nothing
end

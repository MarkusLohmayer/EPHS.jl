

"""
    map(f, expr::SymExpr, T::Type{<:SymExpr}) -> SymExpr

Transform a symbolic expression using a function `f : T -> SymExpr`.
When descending from the root into the expression tree,
whenever a `node` of type `T` comes up,
it is replaced by the node `f(node)`
"""
function Base.map(f::Function, expr::SymExpr, T::Type{<:SymExpr})::SymExpr
  if expr isa T
    return f(expr)
  elseif expr isa SymOp
    # By default, the transform is applied to all arguments of an operation
    args = map(name -> getfield(expr, name), fieldnames(typeof(expr)))
    transformed_args = map(args) do argument
      if argument isa SymExpr # for operations with fixed arity
        return map(f, argument, T)
      elseif argument isa Tuple{Vararg{SymExpr}}  # for n-ary operations like Add
        return map(argument) do tuple_element
          map(f, tuple_element, T)
        end
      else
        error("should not reach here")
      end
    end
    return typeof(expr)(transformed_args...)
  else
    # identity transform as fallback case
    return expr
  end
end

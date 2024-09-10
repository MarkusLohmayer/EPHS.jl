
function buildfn(args::Tuple{Vararg{SymVar}}, expr::SymExpr)
  quote
    function ($((ast(s) for s in args)...))
      $(ast(expr))
    end
  end
end

buildfn(arg::SymVar, expr::SymExpr) = buildfn((arg,), expr)

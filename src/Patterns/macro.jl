
# function parse_var(e::Union{Expr,Symbol})
#   @match e begin
#     :_ => PACKAGE_ROOT
#     a::Symbol => getproperty(PACKAGE_ROOT, a)
#     Expr(:(.), e′, QuoteNode(x)) => parse_var(e′).x
#   end
# end


"""
A modified version of the relation macro supporting namespacing

TODO: this currently does not support unexposed junctions. We should support
unexposed junctions.

See some examples below:

```
@rhizome ThRing R(a, b) begin
  X(a, b)
  Y(a, c.x = a)
end

@rhizome ThRing Id(a, b) begin
  _(a, b)
end
```

We can interpret the first rhizome as follows:

1. The rhizome has ports that are typed by types within ThRing. Because
`ThRing` has a `default` type, ports that are not explicitly annotated
will be assumed to be of that type.
2. The name of the rhizome is `R`.
3. The namespace for the external ports of the rhizome is `[a, b]`.
As noted in 1., each of these ports is typed with `default`.
"""
# macro rhizome(head, body)
#   # parse the name and junctions out of `head`
#   junctions = OrderedDict{DtryVar,Junction}()
#   (name, args) = @match head begin
#     Expr(:call, name::Symbol, args...) => (name, args)
#   end
#   for arg in args
#     (jname, typeexpr) = @match arg begin
#       jname::Symbol => (jname, :default)
#       Expr(:(.), _, _) => (arg, :default)
#       Expr(:(::), jname, type) => (jname, type)
#     end
#     v = parse_var(jname)
#     junctions[v] = Junction(true, :type)
#   end
#   junctions = Dtry(junctions)
#
#   boxes = OrderedDict{DtryVar,Dtry{InnerPort}}()
#   # for each line in body, add a box to boxes
#   for line in body.args
#     (box, args) = @match line begin
#       _::LineNumberNode => continue
#       Expr(:call, name, args...) => (parse_var(name), args)
#     end
#     interface = OrderedDict{DtryVar,InnerPort}()
#     for arg in args
#       (pname, junction) = @match arg begin
#         pname::Symbol => (pname, pname)
#         Expr(:(.), _, _) => (arg, arg)
#         Expr(:(=), pname, junction) => (pname, junction)
#         Expr(:kw, pname, junction) => (pname, junction)
#         _ => error("unknown port pattern for box $box: $arg")
#       end
#       v = parse_var(pname)
#       jvar = parse_var(junction)
#       j = junctions[jvar]
#       interface[v] = InnerPort(j.type, jvar)
#     end
#     boxes[box] = Dtry(interface)
#   end
#   :(
#     $name = $Rhizome(
#       $(Dtry(boxes)),
#       $(junctions),
#     )
#   ) |> esc
# end

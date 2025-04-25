module TestMoreBase

using Test
using EPHS.MoreBase


struct Foo
  x::Int
end
x = Foo.((1, 2, 3))
xx = (x, x..., x, Foo(42))
yy = (x..., x..., x..., Foo(42))
@test flatten(xx) == yy

end

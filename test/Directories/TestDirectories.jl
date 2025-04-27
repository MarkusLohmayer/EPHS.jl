module TestDirectories

using Test
using EPHS.MoreBase: flatten
using EPHS.Directories


include("nonempty.jl")


@test Dtry{Int}() == Dtry{Int}()

# @btime begin
d1 = Dtry(:a => Dtry(10), :b => Dtry(20), :c => Dtry(30))
d2 = Dtry(:x => d1, :y => Dtry(40), :z => Dtry(50))
@test d1.c[] == 30
@test d2.x.c[] == 30
@test d2.x == d1
# end

@test_throws DtryLeafError Dtry{Int}()[]
@test_throws DtryLeafError d2.x[]
@test_throws DtryBranchError d2.a

d3 = Dtry(:a => Dtry(110), :b => Dtry(120), :c => Dtry(130))
d4 = Dtry(:x => d3, :y => Dtry(140), :z => Dtry(150))
@test map(x -> x + 100, d2) == d4

@test zipmap((x, y) -> x + y, d2, d2, Int) == map(x -> 2x, d2, Int)


d5 = Dtry(:q => Dtry(13), :u => d2, :v => Dtry(14))
d6 = Dtry(:i => d5, :j => d5)
@test d6.i == d6.j
@test d6.i.u.x.a[] == 10
@test d6[■.i.u.x.a] == 10

@test haspath(d6, ■.i.u.x.a)
@test haspath(d6, ■.j.u.z)
@test !haspath(d6, ■.i.u.z.a)

@test hasprefix(d6, ■.i.u.x.a)
@test hasprefix(d6, ■.i.u.x)
@test hasprefix(d6, ■.i.u)
@test hasprefix(d6, ■.i)
@test hasprefix(d6, ■)
@test !haspath(d6, ■.k)


@test flatten(Dtry{Dtry{Int}}()) == Dtry{Int}()


dd1 = Dtry(:x => Dtry(Dtry(:y => d1)), :z => Dtry{Dtry{Int}}())
d7 = Dtry(:x => Dtry(:y => d1))
@test flatten(dd1) == d7


dd2 = Dtry(:x => Dtry(d1), :y => Dtry(d5))
d8 = Dtry(:x => d1, :y => d5)
@test flatten(dd2) == d8


dd3 = Dtry(:x => Dtry(Dtry(:y => d3)), :z => Dtry(d4))
d9 = Dtry(:x => Dtry(:y => d3), :z => d4)
@test flatten(dd3) == d9

# 14.000 μs (424 allocations: 20.25 KiB)
dd4 = Dtry(
  :a => Dtry(:b => Dtry(d8)),
  :c => Dtry(:d => Dtry(:h => Dtry(d1)),
    :e => Dtry(:g => Dtry(:i => Dtry(d2)))),
  :f => Dtry(d3)
)
d0 = Dtry(
  :a => Dtry(:b => d8),
  :c => Dtry(:d => Dtry(:h => d1),
    :e => Dtry(:g => Dtry(:i => d2))),
  :f => d3
)
@test flatten(dd4) == d0

t1 = Dtry(
  :a => Dtry(1),
  :b => Dtry(
    :a => Dtry(2),
    :c => Dtry(3),
  ),
)
t2 = Dtry(
  :b => Dtry(
    :z => Dtry(4),
  ),
  :d => Dtry(5)
)
t3 = Dtry(
  :a => Dtry(1),
  :b => Dtry(
    :a => Dtry(2),
    :c => Dtry(3),
    :z => Dtry(4),
  ),
  :d => Dtry(5)
)
@test merge(t1, t2) == t3


t4 = Dtry(
  :a => Dtry(("a", 1)),
  :b => Dtry(
    :a => Dtry(("b.a", 2)),
    :c => Dtry(("b.c", 3)),
  ),
)
@test mapwithpath((path, value) -> (string(path), value), t1, Tuple{String,Int}) == t4

@test filtermap(x -> isodd(x) ? Some(x) : nothing, t3, Int) == Dtry(
  :a => Dtry(1),
  :b => Dtry(
    :c => Dtry(3),
  ),
  :d => Dtry(5)
)

@test filtermapwithpath(t3, String) do path, x
  isodd(x) ? Some(string(path, "=>", x)) : nothing
end == Dtry(
  :a => Dtry("■.a=>1"),
  :b => Dtry(
    :c => Dtry("■.b.c=>3"),
  ),
  :d => Dtry("■.d=>5")
)

end

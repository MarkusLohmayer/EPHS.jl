module TestDirectories

using Test, EPHS.Directories, EPHS.MoreBase

include("nonempty.jl")

const D = Dtry{Int}
const DD = Dtry{Dtry{Int}}

@test D() == D()

# @btime begin
d1 = D(:a => D(10), :b => D(20), :c => D(30))
d2 = D(:x => d1, :y => D(40), :z => D(50))
@test d1.c[] == 30
@test d2.x.c[] == 30
@test d2.x == d1
# end

@test_throws DtryLeafError D()[]
@test_throws DtryLeafError d2.x[]
@test_throws DtryBranchError d2.a

d3 = D(:a => D(110), :b => D(120), :c => D(130))
d4 = D(:x => d3, :y => D(140), :z => D(150))
@test map(x -> x + 100, d2) == d4

@test zipmap((x, y) -> x + y, d2, d2, Int) == map(x -> 2x, d2, Int)


d5 = D(:q => D(13), :u => d2, :v => D(14))
d6 = D(:i => d5, :j => d5)
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


@test flatten(DD()) == D()


dd1 = DD(:x => DD(D(:y => d1)), :z =>  DD())
d7 = D(:x => D(:y => d1))
@test flatten(dd1) == d7


dd2 = DD(:x => DD(d1), :y => DD(d5))
d8 = D(:x => d1, :y => d5)
@test flatten(dd2) == d8


dd3 = DD(:x => DD(D(:y => d3)), :z => DD(d4))
d9 = D(:x => D(:y => d3), :z => d4)
@test flatten(dd3) == d9

# 14.000 μs (424 allocations: 20.25 KiB)
dd4 = DD(
  :a => DD(:b => DD(d8)),
  :c => DD(:d => DD(:h => DD(d1)),
  :e => DD(:g => DD(:i => DD(d2)))),
  :f => DD(d3)
)
d0 = D(
  :a => D(:b => d8),
  :c => D(:d => D(:h => d1),
  :e => D(:g => D(:i => d2))),
  :f => d3
)
@test flatten(dd4) == d0

t1 = D(
  :a => D(1),
  :b => D(
    :a => D(2),
    :c => D(3),
  ),
)
t2 = D(
  :b => D(
    :z => D(4),
  ),
  :d => D(5)
)
t3 = D(
  :a => D(1),
  :b => D(
    :a => D(2),
    :c => D(3),
    :z => D(4),
  ),
  :d => D(5)
)
@test merge(t1, t2) == t3


t4 = Dtry{Tuple{String,Int}}(
  :a => Dtry{Tuple{String,Int}}(("a", 1)),
  :b => Dtry{Tuple{String,Int}}(
    :a => Dtry{Tuple{String,Int}}(("b.a", 2)),
    :c => Dtry{Tuple{String,Int}}(("b.c", 3)),
  ),
)
@test mapwithpath((path, value) -> (string(path), value), t1, Tuple{String,Int}) == t4

end

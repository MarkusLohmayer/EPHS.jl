
const N = NonEmptyDtry{Int}
const NN = NonEmptyDtry{NonEmptyDtry{Int}}


# @btime begin
n1 = N(:a => N(10), :b => N(20), :c => N(30))
n2 = N(:x => n1, :y => N(40), :z => N(50))
@test n1.c[] == 30
@test n2.x.c[] == 30
@test n2.x == n1
# end


n3 = N(:a => N(110), :b => N(120), :c => N(130))
n4 = N(:x => n3, :y => N(140), :z => N(150))
@test map(x -> x + 100, n2) == n4


n5 = N(:q => N(13), :u => n2, :v => N(14))
n6 = N(:i => n5, :j => n5)
@test n6.i == n6.j
@test n6.i.u.x.a[] == 10
@test n6[■.i.u.x.a] == 10


@test zip(n2, n2) == Dtry{Tuple{Int,Int}}(
  :x => Dtry{Tuple{Int,Int}}(
    :a => Dtry{Tuple{Int,Int}}((10, 10)),
    :b => Dtry{Tuple{Int,Int}}((20, 20)),
    :c => Dtry{Tuple{Int,Int}}((30, 30)),
  ),
  :y => Dtry{Tuple{Int,Int}}((40, 40)),
  :z => Dtry{Tuple{Int,Int}}((50, 50)),
)



nn1 = NN(:x => NN(N(:y => n1)))
n7 = N(:x => N(:y => n1))
@test flatten(nn1) == n7


nn2 = NN(:x => NN(n1), :y => NN(n5))
n8 = N(:x => n1, :y => n5)
@test flatten(nn2) == n8


nn3 = NN(:x => NN(N(:y => n3)), :z => NN(n4))
n9 = N(:x => N(:y => n3), :z => n4)
@test flatten(nn3) == n9


nn4 = NN(
  :a => NN(:b => NN(n8)),
  :c => NN(:d => NN(:h => NN(n1)),
  :e => NN(:g => NN(:i => NN(n2)))),
  :f => NN(n3)
)
n0 = N(
  :a => N(:b => n8),
  :c => N(:d => N(:h => n1),
  :e => N(:g => N(:i => n2))),
  :f => n3
)
@test flatten(nn4) == n0

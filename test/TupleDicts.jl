module TestTupleDicts

using Test
using EPHS.TupleDicts

@test_throws ArgumentError TupleDict((:a, :b), (1, 2, 3))
@test_throws ArgumentError TupleDict((:a, :a), (1, 2))

d = TupleDict((:a, :b, :c, :d, :e), Tuple(1:5))
@test d[:e] == 5
@test_throws KeyError d[:f]

d2 = TupleDict(:a => 1, :b => 2, :c => 3, :d => 4, :e => 5)
@test d == d2

end

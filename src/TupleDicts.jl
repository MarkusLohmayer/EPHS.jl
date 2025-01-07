"""
A minimal implementation of tuple-backed dictionaries.
Dictionaries are ordered, immutable, and non-empty.
"""
module TupleDicts

export TupleDict

"""
A tuple dictionary is defined by a key `K` and a value `V`.
The number of keys and values must have
* the same length
* be non-zero
* and the keys must be unique.
"""
struct TupleDict{K,V} <: AbstractDict{K,V}
  ks::Tuple{Vararg{K}}
  vs::Tuple{Vararg{V}}

  function TupleDict{K,V}(ks::Tuple{Vararg{K}}, vs::Tuple{Vararg{V}}) where {K,V}
    nk = length(ks)
    nv = length(vs)
    nk == nv ||
      throw(ArgumentError("keys have length $nk, whereas values have length $nv"))
    allunique(ks) || throw(ArgumentError("keys are not unique"))
    new{K,V}(ks, vs)
  end
end


#flatten of TupleDict? Similar to MoreBase.Flatten?
TupleDict(ks::Tuple{Vararg{K}}, vs::Tuple{Vararg{V}}) where {K,V} = TupleDict{K,V}(ks, vs)


TupleDict{K,V}(ps::Pair...) where {K,V} = TupleDict{K,V}(first.(ps), last.(ps))


TupleDict(ps::Pair{K,V}...) where {K,V} = TupleDict{K,V}(first.(ps), last.(ps))


"""
    Base.length(d::TupleDict)
Returns the length of TupleDict `d`.
"""
Base.length(d::TupleDict) = length(d.ks)


"""
    Base.keys(d::TupleDict)
Returns the keys `K` of TupleDict `d`.
"""
Base.keys(d::TupleDict) = d.ks


"""
    Base.values(d::TupleDict)
Returns the values `V` of TupleDict `d`.
"""
Base.values(d::TupleDict) = d.vs


# i = iteration number/state
# Julia's iteration interface:
# return key-value pair and iteration state
# return nothing to stop iteration
"""
    Base.iterate(d::TupleDict, i::int)
Returns key-value pair of TupleDict `d` and iteration state starting incrementally from `i`.
"""
Base.iterate(d::TupleDict, i=1) =
  i ≤ length(d.ks) ? (d.ks[i] => d.vs[i], i + 1) : nothing


# get value `V` by key `K`
"""
    Base.get(d::TupleDict{K,V}, key::K, default)
Return value `V` stored for the given key `k`, or the given default value if no mapping for the key is present.
"""
function Base.get(d::TupleDict{K,V}, key::K, default) where {K,V}
  for i in 1:length(d.ks)
    candidate = @inbounds d.ks[i]
    isequal(candidate, key) && return @inbounds d.vs[i]::V
  end
  return default
end


# TODO should not be required (benchmark)
# function Base.getindex(d::TupleDict{K,V}, key::K) where {K,V}
#   for i in 1:length(d.ks)
#     candidate = @inbounds d.ks[i]
#     isequal(candidate, key) && return @inbounds d.vs[i]::V
#   end
#   throw(KeyError(key))
# end


# Assumes that K !== Int
# Base.getindex(d::TupleDict{K,V}, i::Int) where {K,V} = Pair{K,V}(d.ks[i], d.vs[i])

end

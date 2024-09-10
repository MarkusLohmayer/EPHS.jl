"""
A minimal implementation of tuple-backed dictionaries.
Dictionaries are ordered, immutable, and non-empty.
"""
module TupleDicts

export TupleDict


struct TupleDict{K,V} <: AbstractDict{K,V}
  ks::Tuple{Vararg{K}}
  vs::Tuple{Vararg{V}}

  function TupleDict{K,V}(ks::Tuple{Vararg{K}}, vs::Tuple{Vararg{V}}) where {K,V}
    nk = length(ks)
    nv = length(vs)
    nk == nv ||
      throw(ArgumentError("keys have length $nk, whereas values have length $nv"))
    nk > 0 || throw(ArgumentError("length of keys and values must be nonzero"))
    allunique(ks) || throw(ArgumentError("keys are not unique"))
    new{K,V}(ks, vs)
  end
end


TupleDict(ks::Tuple{Vararg{K}}, vs::Tuple{Vararg{V}}) where {K,V} = TupleDict{K,V}(ks, vs)


TupleDict{K,V}(ps::Pair...) where {K,V} = TupleDict{K,V}(first.(ps), last.(ps))


TupleDict(ps::Pair{K,V}...) where {K,V} = TupleDict{K,V}(first.(ps), last.(ps))


Base.length(d::TupleDict) = length(d.ks)


Base.keys(d::TupleDict) = d.ks


Base.values(d::TupleDict) = d.vs


# i = iteration number/state
# Julia's iteration interface:
# return key-value pair and iteration state
# return nothing to stop iteration
Base.iterate(d::TupleDict, i=1) =
  i ≤ length(d.ks) ? (d.ks[i] => d.vs[i], i + 1) : nothing


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

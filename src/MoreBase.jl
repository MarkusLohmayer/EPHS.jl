"""
Things that might be a good fit for Julia's Base
"""
module MoreBase

export flatten # Note: Base.Iterators.flatten exists
export BitonicSort


using Base: tail


# `flatten(::Tuple)` is currently not used anywhere

"""
Flatten hierarchically nested tuples.

# Example
```jldoctest
julia> flatten((1, (2, (3, 4), 5), 6))
(1, 2, 3, 4, 5, 6)
```
"""
flatten(t::Tuple) = _flatten_tuple(t)
_flatten_tuple(::Tuple{}) = ()
_flatten_tuple(t::Tuple) = (_flatten_tuple(t[1])..., _flatten_tuple(tail(t))...)
_flatten_tuple(x::Any) = (x,)


# The following implementation of BitonicSort without parallelization
# is not faster than, say, QuickSort.
# Source: StaticArrays/src/sort.jl

struct BitonicSortAlg <: Base.Sort.Algorithm end

"""
BitonicSort

Indicate that a sorting function should use the bitonic sort algorithm, which is not stable.

Characteristics:
- current implementation only works on `NTuple`s
- not stable: does not preserve the ordering of elements that compare equal
- uses generated function to compile sort network for given input type
- theoretically good performance if implementation would use parallelism
  and if network is already compiled for a given input type

# Example
```jldoctest
julia> sort((9, 2, 3, 1); alg=BitonicSort)
(1, 2, 3, 9)
```
"""
const BitonicSort = BitonicSortAlg()

@generated function Base.sort(
  a::NTuple{N};
  alg::BitonicSortAlg,
  lt::Function=isless,
  by::Function=identity
) where {N}

  function swap_expr(i, j, rev)
    ai = Symbol('a', i)
    aj = Symbol('a', j)
    return :(($ai, $aj) = @inbounds (lt(by($ai), by($aj)) ⊻ $rev) ? ($ai, $aj) : ($aj, $ai))
  end

  function merge_exprs(idx, rev)
    exprs = Expr[]
    length(idx) == 1 && return exprs

    ci = 2^(ceil(Int, log2(length(idx))) - 1)
    for i in first(idx):last(idx)-ci
      push!(exprs, swap_expr(i, i + ci, rev))
    end
    append!(exprs, merge_exprs(idx[1:ci], rev))
    append!(exprs, merge_exprs(idx[ci+1:end], rev))
    return exprs
  end

  function sort_exprs(idx, rev=false)
    exprs = Expr[]
    length(idx) == 1 && return exprs

    append!(exprs, sort_exprs(idx[1:end÷2], !rev))
    append!(exprs, sort_exprs(idx[end÷2+1:end], rev))
    append!(exprs, merge_exprs(idx, rev))
    return exprs
  end

  idx = 1:N
  symlist = (Symbol('a', i) for i in idx)
  return quote
    Base.@_inline_meta
    ($(symlist...),) = a
    ($(sort_exprs(idx)...))
    return ($(symlist...),)
  end
end

end

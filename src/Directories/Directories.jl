"""
Directories -
the [`NonEmptyDtry`](@ref) and [`Dtry`](@ref) monads

A nonempty directory of `T`s (`NonEmptyDtry{T}`)
is essentially a tree
whose leaves hold values of type `T`.
Each value is addressed by
the path from the root node to the respective leaf,
given by a list of `Symbol`s, see [`DtryPath`](@ref).

The *monad unit* sends a value of type `T` to
a tree consisting only of a leaf holding the value.

The *monad multiplication* flattens a directory of directories of `T`s
into a directory of `T`s by grafting the trees stored at the leaves
directly onto their respective parent nodes.

A (possibly empty) directory of `T`s (`Dtry{T}`)
is either empty or it is a nonempty directory of `T`s.
The `Dtry` monad is hence obtained by composing
the `NonEmptyDtry` monad with the 'Maybe monad'.
The composition of the monads relies on a distributive law.
Since subdirectories (subtrees) of a directory cannot be empty,
the distributive law filters out any empty directories at the leaves,
as they cannot be grafted onto their parent nodes.

This module implements directories as an immutable data structure.
Subdirectories are stored in lexicographic order
to ensure that two directories with the same set of paths (namespace)
and the same associated values are equal.

The implementation supports
simple access of subdirectories and values,
pretty-printing,
iteration,
mapping, filtering, merging, etc.
"""
module Directories

export AbstractDtry
export NonEmptyDtry, Dtry
export print_dtry, print_dtry_repr
export DtryAccessError, DtryBranchError, DtryLeafError
export DtryPath, ■
export hasprefix, haspath
export mapwithpath, zipmap, zipmapwithpath, filtermap, filtermapwithpath, mapreducewithpath
export foreachpath, foreachvalue


using ..MoreBase
using ..TupleDicts


"""
The concrete subtypes of `AbstractDtry` are
[`NonEmptyDtry`](@ref) and [`Dtry`](@ref).
"""
abstract type AbstractDtry{T} end


# Leaf nodes hold values.
struct DtryLeaf{T}
  value::T
end


# Internal nodes branch out to at least one
# leaf node (value) or internal node (subdirectory).
# We have `S = NonEmptyDtry{T}`,
# which is needed to avoid a circular dependency
# between `DtryNode` and `NonEmptyDtry`.
struct DtryNode{S}
  branches::TupleDict{Symbol,S}
end


"""
A `NonEmptyDtry{T}` either contains a single value of type `T`
or it has at least one non-empty subdirectory of `T`s.
"""
struct NonEmptyDtry{T} <: AbstractDtry{T}
  leaf_or_node::Union{
      DtryLeaf{T},
      DtryNode{NonEmptyDtry{T}}
  }

  NonEmptyDtry{T}(value::T) where {T} = new{T}(DtryLeaf{T}(value))

  function NonEmptyDtry{T}(pairs::Vararg{Pair{Symbol,NonEmptyDtry{T}}}) where {T}
    length(pairs) == 0 && error("`NonEmptyDtry` cannot be empty")
    pairs = sort(pairs; alg=BitonicSort, by=p->p.first)
    new{T}(DtryNode{NonEmptyDtry{T}}(TupleDict{Symbol,NonEmptyDtry{T}}(pairs...)))
  end
end


"""
    NonEmptyDtry(value::T) -> NonEmptyDtry{T}

Construct a non-empty directory,
which contains just a single value (monad unit).
"""
NonEmptyDtry(value::T) where {T} = NonEmptyDtry{T}(value)


"""
    NonEmptyDtry(pairs::Vararg{Pair{Symbol,NonEmptyDtry{T}}}) -> NonEmptyDtry{T}

Construct a non-empty directory of `T`s from a number of
pairs of names and non-empty subdirectories.
"""
NonEmptyDtry(pairs::Vararg{Pair{Symbol,NonEmptyDtry{T}}}) where {T} =
  NonEmptyDtry{T}(pairs...)


"""
A `Dtry{T}` is either empty or it wraps
a [`NonEmptyDtry`](@ref) of `T`s.
"""
struct Dtry{T} <: AbstractDtry{T}
  nothing_or_nonempty::Union{
      Nothing,
      NonEmptyDtry{T}
  }

  @doc """
      Dtry{T}()

  Construct an empty directory of `T`s.
  """
  Dtry{T}() where {T} = new{T}(nothing)

  Dtry{T}(value::T) where {T} = new{T}(NonEmptyDtry{T}(value))

  function Dtry{T}(pairs::Vararg{Pair{Symbol,<:AbstractDtry{T}}}) where {T}
    nonempty_dirs = filter(pairs) do (_, dtry)
      !isempty(dtry)
    end
    length(nonempty_dirs) == 0 && return new{T}(nothing)
    unwrapped = map(nonempty_dirs) do (name, dtry)
      name => nothing_or_nonempty(dtry)
    end
    new{T}(NonEmptyDtry{T}(unwrapped...))
  end
end


"""
    Dtry(value::T) -> Dtry{T}

Construct a directory,
which contains just a single value (monad unit).
"""
Dtry(value::T) where {T} = Dtry{T}(value)


"""
    Dtry(pairs::Vararg{Pair{Symbol,Dtry{T}}}) -> Dtry{T}

Construct a directory of `T`s from a number of
pairs of names and subdirectories.
Empty subdirectories are filtered out.
"""
Dtry(pairs::Vararg{Pair{Symbol,<:AbstractDtry{T}}}) where {T} = Dtry{T}(pairs...)


# Needed to have custom `getproperty(::AbstractDtry)` for accessing subdirectories
leaf_or_node(dtry::NonEmptyDtry) = getfield(dtry, :leaf_or_node)
nothing_or_nonempty(dtry::Dtry) = getfield(dtry, :nothing_or_nonempty)
nothing_or_nonempty(dtry::NonEmptyDtry) = dtry


"""
    isempty(dtry::AbstractDtry) -> Bool

Returns `true` if the given directory is empty.
"""
Base.isempty(dtry::Dtry) = isnothing(nothing_or_nonempty(dtry))
Base.isempty(dtry::NonEmptyDtry) = false


function Base.:(==)(dtry1::Dtry{T}, nonempty2::NonEmptyDtry{T}) where {T}
  if isempty(dtry1)
    return false
  else
    nonempty1 = nothing_or_nonempty(dtry1)
    return nonempty1 == nonempty2
  end
end


Base.:(==)(nonempty1::NonEmptyDtry{T}, dtry2::Dtry{T}) where {T} = dtry2 == nonempty1


"""
    length(dtry::NonEmptyDtry) -> Int

Returns the number of values (leaves) in the given directory.
"""
function Base.length(dtry::NonEmptyDtry)::Int
  if leaf_or_node(dtry) isa DtryLeaf
    return 1
  else
    node = leaf_or_node(dtry)
    return sum(length(branch) for branch in values(node.branches))
  end
end


"""
    length(dtry::Dtry) -> Int

Returns the number of values (leaves) in the given directory.
"""
Base.length(dtry::Dtry)::Int =
  isempty(dtry) ? 0 : length(nothing_or_nonempty(dtry))


# display of directories in Julia REPL
include("show.jl")

# access subdirectories and values
include("access.jl")

# access subdirectories based on a path
include("path.jl")

# map over directories (monads are functors)
include("map.jl")

# flatten directories of directories (monad multiplication)
include("flatten.jl")

# iterate over directories
include("iterate.jl")

# merge directories
include("merge.jl")

end

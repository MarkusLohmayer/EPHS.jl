"""
Directories - the `NonEmptyDtry` and `Dtry` monads

A nonempty directory of `T`s is essentially a tree
whose leaves hold values of type `T`.
A path to a leaf is given by a list of `Symbol`s.
The 'monad unit' sends a value of type `T` to
a tree consisting only of one leaf holding the value.
Monad multiplication flattens a directory of directories of `T`s
into a directory of `T`s by grafting the trees stored at the leaves
onto their respective parent nodes.
A (possibly empty) directory is either nothing or a nonempty directory.
The `Dtry` monad is hence obtained by composing the `NonEmptyDtry` monad
with the 'Maybe monad', based on a distributive law,
which filters out empty directories at the leaves.
"""
module Directories

export AbstractDtry
export DtryLeaf, DtryNode
export NonEmptyDtry, Dtry
export leaf_or_node, nothing_or_nonempty
export print_dtry
export DtryAccessError, DtryBranchError, DtryLeafError
export DtryPath, ■, nothing_or_link
export mapwithpath, zipmap, zipmapwithpath, filtermap
export foreachpath, foreachvalue

import ..MoreBase: flatten


using ..TupleDicts


"Subtypes are `Dtry` and `NonEmptyDtry`."
abstract type AbstractDtry{T} end


"Leaf nodes hold values."
struct DtryLeaf{T}
  value::T
end


"""
Internal nodes branch out to at least one
leaf node (value) or internal node (subdirectory).
"""
struct DtryNode{S} # S = NonEmptyDtry{T}
  branches::TupleDict{Symbol,S}
end


"""
A nonempty directory either wraps a single value (monad unit)
or a root/internal node (top-level directory).
"""
struct NonEmptyDtry{T} <: AbstractDtry{T}
  leaf_or_node::Union{
      DtryLeaf{T},
      DtryNode{NonEmptyDtry{T}}
  }

  "Construct a nonempty directory from a single value (monad unit)"
  NonEmptyDtry{T}(value::T) where {T} = new{T}(DtryLeaf{T}(value))

  "Construct a nonempty directory from named nonempty subdirectories"
  function NonEmptyDtry{T}(pairs::Vararg{Pair{Symbol,NonEmptyDtry{T}}}) where {T}
    length(pairs) == 0 && error("`NonEmptyDtry` cannot be empty")
    new{T}(DtryNode{NonEmptyDtry{T}}(TupleDict{Symbol,NonEmptyDtry{T}}(pairs...)))
  end
end


"A directory is either empty or nonempty."
struct Dtry{T} <: AbstractDtry{T}
  nothing_or_nonempty::Union{
      Nothing,
      NonEmptyDtry{T}
  }

  "Construct an empty directory."
  Dtry{T}() where {T} = new{T}(nothing)

  "Construct a directory from a single value (monad unit)"
  Dtry{T}(value::T) where {T} = new{T}(NonEmptyDtry{T}(value))

  "Construct a directory from named subdirectories"
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


NonEmptyDtry(value::T) where {T} = NonEmptyDtry{T}(value)


NonEmptyDtry(pairs::Vararg{Pair{Symbol,NonEmptyDtry{T}}}) where {T} = NonEmptyDtry{T}(pairs...)


Dtry(value::T) where {T} = Dtry{T}(value)


Dtry(pairs::Vararg{Pair{Symbol,<:AbstractDtry{T}}}) where {T} = Dtry{T}(pairs...)


# Needed to have custom `getproperty(::AbstractDtry)` for accessing subdirectories
leaf_or_node(dtry::NonEmptyDtry) = getfield(dtry, :leaf_or_node)
nothing_or_nonempty(dtry::Dtry) = getfield(dtry, :nothing_or_nonempty)
nothing_or_nonempty(dtry::NonEmptyDtry) = dtry


Base.isempty(dtry::NonEmptyDtry) = false
Base.isempty(dtry::Dtry) = isnothing(nothing_or_nonempty(dtry))


function Base.:(==)(dtry1::Dtry{T}, nonempty2::NonEmptyDtry{T}) where {T}
  if isempty(dtry1)
    return false
  else
    nonempty1 = nothing_or_nonempty(dtry1)
    return nonempty1 == nonempty2
  end
end


Base.:(==)(nonempty1::NonEmptyDtry{T}, dtry2::Dtry{T}) where {T} = dtry2 == nonempty1


function Base.length(dtry::NonEmptyDtry)
  if leaf_or_node(dtry) isa DtryLeaf
    return 1
  else
    node = leaf_or_node(dtry)
    return sum(length(branch) for branch in values(node.branches))
  end
end


Base.length(dtry::Dtry) = isempty(dtry) ? 0 : length(nothing_or_nonempty(dtry))


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

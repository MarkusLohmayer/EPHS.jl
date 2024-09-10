"""
Things that might be a good fit for Julia's Base
"""
module MoreBase

# Note: Base.Iterators.flatten exists
export flatten


using Base: tail


"Flatten tuples of tuples"
flatten(t::Tuple) = (flatten(t[1])..., flatten(tail(t))...)
flatten(::Tuple{}) = ()
flatten(x) = (x,)

end

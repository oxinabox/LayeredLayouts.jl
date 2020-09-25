# for things that are not actually related to the problem itself

"""
    try_get(collection, inds...)

Like `getindex`, except returns `nothing` if not found or
if the collection itsself is `nothing`.
"""
try_get(::Nothing, inds...) = nothing
try_get(x, inds...) = get(x, inds, nothing)

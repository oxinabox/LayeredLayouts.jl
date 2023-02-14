# for things that are not actually related to the problem itself

"""
    try_get(collection, inds...)

Like `getindex`, except returns `nothing` if not found or
if the collection itsself is `nothing`.
"""
try_get(::Nothing, inds...) = nothing
try_get(x, inds...) = get(x, inds, nothing)

"""
    rotatecoords(xs::AbstractVector, ys::AbstractVector, paths::AbstractDict, θ)

Rotate coordinates `xs`, `ys` and paths `paths` by `angle`
"""
function rotatecoords(xs::AbstractVector, ys::AbstractVector, paths::AbstractDict, θ)
    # rotation matrix
    r = [cos(θ) -sin(θ); sin(θ) cos(θ)]
    points = vcat.(xs, ys)
    newpoints = [r * pointvec for pointvec in points]
    newpaths = Dict(k => let newpath = [r * pointvec for pointvec in vcat.(v...)]
             (getindex.(newpath, 1), getindex.(newpath, 2))
         end
         for (k,v) in paths)
    return getindex.(newpoints, 1), getindex.(newpoints, 2), newpaths
end

"""
    rotatecoords!(xs::AbstractVector, ys::AbstractVector, paths::AbstractDict, θ)

Rotate coordinates `xs`, `ys` and paths `paths` by `angle`
"""
function rotatecoords!(xs::AbstractVector, ys::AbstractVector, paths::AbstractDict, θ)
    # rotation matrix
    r = [cos(θ) -sin(θ); sin(θ) cos(θ)]
    points = vcat.(xs, ys)
    newpoints = [r * pointvec for pointvec in points]
    xs .= getindex.(newpoints, 1)
    ys .= getindex.(newpoints, 2)
    for (k,v) in paths
        newpath = [r * pointvec for pointvec in vcat.(v...)]
        paths[k] = (getindex.(newpath, 1), getindex.(newpath, 2))
    end
end

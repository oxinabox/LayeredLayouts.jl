module LayeredLayouts
using JuMP
using Ipopt
using Cbc
using IterTools: IterTools
using LightGraphs
using Random

export LayeredMinDistOne
export solve_positions

abstract type AbstractLayout end

include("graph_properties.jl")
include("layering.jl")

include("min_dist_one.jl")
include("sugiyama.jl")

end

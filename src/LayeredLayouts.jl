module LayeredLayouts
using Dates
using JuMP
using ECOS
using Ipopt
using Cbc
using IterTools: IterTools
using LightGraphs
using Random

export LayeredMinDistOne, Zarate
export solve_positions

abstract type AbstractLayout end

include("utils.jl")

include("graph_properties.jl")
include("layering.jl")

include("min_dist_one.jl")
include("zarate.jl")

end

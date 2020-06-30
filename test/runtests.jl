using Plots
using LightGraphs
using LayeredLayouts
using Test
using VisualRegressionTests

@testset "LayeredLayouts.jl" begin
    include("test_utils.jl")
    include("examples.jl")

    include("min_dist_one.jl")
    
end

using Plots
using LightGraphs
using LayeredLayouts
using Test
using VisualRegressionTests

@testset "LayeredLayouts.jl" begin
    include("test_utils.jl")
    include("examples.jl")

    @testset "$fn" for fn in (
        "min_dist_one.jl"
    )
        include(fn)
    end
end




using Plots
using LightGraphs
using LayeredLayouts
using Test
using VisualRegressionTests

include("examples.jl")

@testset "LayeredLayouts.jl" begin
    include("demos.jl")
end

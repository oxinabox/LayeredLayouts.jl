using Plots
using Graphs
using LayeredLayouts
using Test
using VisualRegressionTests

include("examples.jl")

@testset "LayeredLayouts.jl" begin
    include("demos.jl")
end

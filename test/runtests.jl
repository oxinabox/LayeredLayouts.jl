# set headless environment for plots
ENV["GKSwstype"] = "100"

using Plots
using Graphs
using LayeredLayouts
using Test
using ReferenceTests

include("examples.jl")

@testset "LayeredLayouts.jl" begin
    include("demos.jl")
end

function quick_plot(graph, xs, ys)
    nv(graph)==length(xs) == length(ys) || error("need 1 position per vertex")
    scatter(xs, ys; markeralpha=0, text=string.(vertices(graph)))

    # now draw connections
    lxs = Float64[]
    lys = Float64[]
    for edge in edges(graph)
        append!(lxs, [xs[edge.src], xs[edge.dst], NaN])
        append!(lys, [ys[edge.src], ys[edge.dst], NaN])
    end
    plot!(lxs, lys; legend=false)
end

ref(fn) = joinpath(@__DIR__, "references", fn * ".png")

@testset "test_utils.jl" begin
    @testset "quick_plot" begin
        @plottest quick_plot(SimpleDiGraph(Edge.([1=>2, 2=>3])), [1,2,5], [1,2,3]) joinpath(@__DIR__, "references", "quick_plot.png")
    end
end

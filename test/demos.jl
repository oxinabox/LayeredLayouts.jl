"helper for testing"
function quick_plot(graph, xs, ys)
    nv(graph)==length(xs) == length(ys) || error("need 1 position per vertex")
    scatter(xs, ys; markeralpha=0, text=string.(vertices(graph)))

    weights_mat = weights(graph)
    # now draw connections
    for edge in edges(graph)
        lxs = [xs[edge.src], xs[edge.dst]]
        lys = [ys[edge.src], ys[edge.dst]]
        w = 5*weights_mat[edge.src, edge.dst]
        plot!(lxs, lys; linewidth=w, alpha=0.7, legend=false)
    end
end

quick_plot_solve(layout, graph) = quick_plot(graph, solve_positions(layout, graph)...) 

@testset "quick_plot" begin
    ref_filename =  joinpath(@__DIR__, "references", "test_utils", "$quick_plot.png")
    @plottest quick_plot(SimpleDiGraph(Edge.([1=>2, 2=>3])), [1,2,5], [1,2,3]) ref_filename true 0.0001
end

@testset "$layout Demos" for layout in (OptimalSugiyama(), LayeredMinDistOne())
    @testset "$graph_name" for graph_name in names(Examples; all=true)
        graph = getfield(Examples, graph_name)
        graph isa AbstractGraph || continue  # skip e.g. `eval`
        ref_filename = joinpath(@__DIR__, "references", string(typeof(layout)), "$graph_name.png")
        mkpath(dirname(ref_filename))
        @plottest quick_plot_solve(layout, graph) ref_filename true 0.0001
    end
end
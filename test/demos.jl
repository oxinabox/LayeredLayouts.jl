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
    @plottest quick_plot(SimpleDiGraph(Edge.([1=>2, 2=>3])), [1,2,5], [1,2,3]) ref_filename true 0.05
end

function test_example(layout, graph_name, tol=0.05)
    @testset "$graph_name" begin
        graph = getfield(Examples, graph_name)
        ref_filename = joinpath(@__DIR__, "references", string(typeof(layout)), "$graph_name.png")
        mkpath(dirname(ref_filename))
        @plottest quick_plot_solve(layout, graph) ref_filename true tol
    end
end

@testset "$layout Demos" for layout in (Zarate(),)
    test_example(layout, :cross)
    test_example(layout, :loop)
    test_example(layout, :medium_pert)
    test_example(layout, :sankey_3twos)
    test_example(layout, :two_lines, 0.02)
    test_example(layout, :xcross)

    test_example(layout, :tree, 0.07)

    #test_example(layout, :large_depgraph)  # too big
    #test_example(layout, :extra_large_depgraph)  # too big
end

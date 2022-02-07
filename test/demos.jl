"helper for testing"
function quick_plot(graph, xs, ys)
    nv(graph)==length(xs) == length(ys) || error("need 1 position per vertex")
    scatter(xs, ys; markeralpha=0, text=string.(vertices(graph)))

    weights_mat = weights(graph)
    # now draw connections
    for edge in edges(graph)
        lxs = [xs[src(edge)], xs[dst(edge)]]
        lys = [ys[src(edge)], ys[dst(edge)]]
        w = 5*weights_mat[edge.src, edge.dst]
        plot!(lxs, lys; linewidth=w, alpha=0.7, legend=false)
    end
end

function quick_plot(graph, xs, ys, paths)
    nv(graph)==length(xs) == length(ys) || error("need 1 position per vertex")
    scatter(xs, ys; markeralpha=0, text=string.(vertices(graph)))

    weights_mat = weights(graph)
    # now draw connections
    for edge in edges(graph)
        lxs, lys = paths[edge]
        w = 5*weights_mat[edge.src, edge.dst]
        plot!(lxs, lys; linewidth=w, alpha=0.7, legend=false)
    end
end

function quick_plot_solve_paths(layout, graph; kwargs...)
    xs, ys, paths = solve_positions(layout, graph; kwargs...)
    quick_plot(graph, xs, ys, paths)
end
function quick_plot_solve_direct(layout, graph; kwargs...)
    xs, ys, _ = solve_positions(layout, graph; kwargs...)
    quick_plot(graph, xs, ys)
end

@testset "quick_plot" begin
    ref_filename =  joinpath(@__DIR__, "references", "test_utils", "$quick_plot.png")
    @plottest quick_plot(SimpleDiGraph(Edge.([1=>2, 2=>3])), [1,2,5], [1,2,3]) ref_filename true 0.05
    paths = Dict(Edge(1, 2) => ([1, 2], [1, 2]), Edge(2, 3) => ([2, 5], [2, 3]))
    @plottest quick_plot(SimpleDiGraph(Edge.([1=>2, 2=>3])), [1,2,5], [1,2,3], paths) ref_filename true 0.05
end

function test_example(layout, graph_name, tol=0.05; kwargs...)
    @testset "$graph_name" begin
        @testset "$graph_name direct" begin
            graph = getfield(Examples, graph_name)
            filename = "$graph_name" * join("_" .* string.(keys(kwargs))) * ".png"
            ref_filename = joinpath(@__DIR__, "references", string(typeof(layout)), "direct", filename)
            mkpath(dirname(ref_filename))
            @plottest quick_plot_solve_direct(layout, graph; kwargs...) ref_filename true tol
        end
        @testset "$graph_name paths" begin
            graph = getfield(Examples, graph_name)
            filename = "$graph_name" * join("_" .* string.(keys(kwargs))) * ".png"
            ref_filename = joinpath(@__DIR__, "references", string(typeof(layout)), "paths", filename)
            mkpath(dirname(ref_filename))
            @plottest quick_plot_solve_paths(layout, graph; kwargs...) ref_filename true tol
        end
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
    test_example(layout, :two_lines, 0.07; force_layer=[6=>3, 8=>4])
    #test_example(layout, :large_depgraph)  # too big
    #test_example(layout, :extra_large_depgraph)  # too big
end

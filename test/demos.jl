"helper for testing"
function quick_plot(graph, xs, ys)
    nv(graph)==length(xs) == length(ys) || error("need 1 position per vertex")
    plt = scatter(xs, ys; markeralpha=0, text=string.(vertices(graph)))

    weights_mat = weights(graph)
    # now draw connections
    for edge in edges(graph)
        lxs = [xs[src(edge)], xs[dst(edge)]]
        lys = [ys[src(edge)], ys[dst(edge)]]
        w = 5*weights_mat[edge.src, edge.dst]
        plt = plot!(lxs, lys; linewidth=w, alpha=0.7, legend=false)
    end
    return plt
end

function quick_plot(graph, xs, ys, paths)
    nv(graph)==length(xs) == length(ys) || error("need 1 position per vertex")
    plt = scatter(xs, ys; markeralpha=0, text=string.(vertices(graph)))

    weights_mat = weights(graph)
    # now draw connections
    for edge in edges(graph)
        lxs, lys = paths[edge]
        w = 5*weights_mat[edge.src, edge.dst]
        plot!(lxs, lys; linewidth=w, alpha=0.7, legend=false)
    end
    return plt
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
    @test_reference ref_filename quick_plot(SimpleDiGraph(Edge.([1=>2, 2=>3])), [1,2,5], [1,2,3])
    paths = Dict(Edge(1, 2) => ([1, 2], [1, 2]), Edge(2, 3) => ([2, 5], [2, 3]))
    @test_reference ref_filename quick_plot(SimpleDiGraph(Edge.([1=>2, 2=>3])), [1,2,5], [1,2,3], paths)
end

function test_example(layout, graph_name; kwargs...)
    @testset "$graph_name" begin
        @testset "$graph_name direct" begin
            graph = getfield(Examples, graph_name)
            filename = "$graph_name" * join("_" .* string.(keys(kwargs))) * ".png"
            ref_filename = joinpath(@__DIR__, "references", string(typeof(layout)), "direct", filename)
            mkpath(dirname(ref_filename))
            @test_reference ref_filename quick_plot_solve_direct(layout, graph; kwargs...)
        end
        @testset "$graph_name paths" begin
            graph = getfield(Examples, graph_name)
            filename = "$graph_name" * join("_" .* string.(keys(kwargs))) * ".png"
            ref_filename = joinpath(@__DIR__, "references", string(typeof(layout)), "paths", filename)
            mkpath(dirname(ref_filename))
            @test_reference ref_filename quick_plot_solve_paths(layout, graph; kwargs...)
        end
    end
end

@testset "$layout Demos" for layout in (Zarate(),)
    test_example(layout, :tiny_depgraph)
    test_example(layout, :cross)
    test_example(layout, :loop)
    test_example(layout, :medium_pert)
    test_example(layout, :sankey_3twos)
    test_example(layout, :two_lines)
    test_example(layout, :xcross)
    test_example(layout, :tree)
    test_example(layout, :two_lines; force_layer=[6=>4, 8=>5])
    test_example(layout, :two_lines; force_order=[1=>2])
    test_example(layout, :two_lines_flipped_vertex_order)
    test_example(layout, :two_lines_flipped_vertex_order; force_equal_layers=[1=>3])
    #test_example(layout, :large_depgraph)  # too big
    #test_example(layout, :extra_large_depgraph)  # too big

    # laying out a graph with specified layering values - which intentionally skips the 16th
    # layer entirely - while also using `force_equal_layers` relative to this layering set
    test_example(layout, :disconnected_components_graph;
        force_layer = [ # note that the 16th layer is skipped
            1=>1, 2=>1, 3=>2, 4=>2, 5=>3, 6=>4, 7=>4, 8=>5, 9=>6, 10=>6, 11=>7, 12=>7, 
            13=>8, 14=>8, 15=>9, 16=>9, 17=>10, 18=>10, 19=>11, 20=>12, 21=>12, 22=>13,
            23=>14, 24=>14, 25=>15, 26=>15, 27=>17, 28=>18, 29=>18, 30=>19, 31=>19, 32=>20,
            33=>20, 34=>21, 35=>22, 36=>22, 37=>23, 38=>24, 39=>24, 40=>25, 41=>25, 42=>26,
            43=>26, 44=>27, 45=>27, 46=>28, 47=>28, 48=>29, 49=>30, 50=>30, 51=>31, 52=>31],
        force_equal_layers = [
            1=>7, 1=>9, 1=>15, 3=>5, 3=>11, 3=>13, 17=>21, 17=>23, 17=>29, 19=>25, 19=>27,
            19=>31])
end

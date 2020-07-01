Base.@kwdef struct LayeredMinDistOne <: AbstractLayout
    layer_max_size_factor::Float64 = 2.0
    interlayer_seperation::Float64 = 1.0
    intralayer_seperation::Float64 = 1.0
end

function determine_layers(::LayeredMinDistOne, graph)
    dists = longest_paths(graph, sources(graph))
    layer_groups = IterTools.groupby(i->dists[i], sort(vertices(graph), by=i->dists[i]))
    return layer_groups
end

function solve_positions(layout::LayeredMinDistOne, graph)
    layer_groups = determine_layers(layout, graph)

    m = Model(optimizer_with_attributes(Ipopt.Optimizer, "print_level"=>0))
    set_silent(m)
    
    ys = map(enumerate(layer_groups)) do (layer, nodes)
        y_min = 0  # IPOpt can't find a solution without this

        # Unclear why capping max size works better than any other way of centering it
        # but it does work better than fixing position of root, different factors can change how good it looks
        y_max = layout.layer_max_size_factor * layout.intralayer_seperation * length(nodes)
        @variable(m, [nodes], base_name="y_$layer", lower_bound=y_min, upper_bound=y_max)
    end

    node_vars = Dict{Int, VariableRef}() # lookup list from vertex index to variable
    for (y, nodes) in zip(ys, layer_groups)
        for n in nodes
            @assert !haskey(node_vars, n)
            node_vars[n] = y[n] # remember this for later
        end
    end

    for (y, nodes) in zip(ys, layer_groups)
        for n1 in nodes
            for n2 in nodes
                n1==n2 && continue
                # With in each layer nodes must be at least 1 unit apart
                @constraint(m, 1 <= (y[n1] - y[n2])^2)
            end
        end
    end

    # Make all links as short as possible
    @objective(m, Min, sum(
        (node_vars[link.src]-node_vars[link.dst])^2 
        for link in edges(graph)
    ))

    optimize!(m)
    
    xs = Float64[]
    ys = Float64[]
    for (layer, nodes) in enumerate(layer_groups)
        for node in nodes
            push!(xs, layer)
            push!(ys, value(node_vars[node]))
        end
    end
    return xs, ys
end

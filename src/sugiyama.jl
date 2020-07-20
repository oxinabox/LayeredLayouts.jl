struct Sugiyama <: AbstractLayout
end

function solve_positions(layout::Sugiyama, original_graph)
    graph = copy(original_graph)
    layer2nodes = layer_by_longest_path_to_source(graph)
    is_dummy_mask = add_dummy_nodes!(graph, layer2nodes)

    order_layers!(graph, layer2nodes)

    xs, ys = assign_coordinates(graph, layer2nodes)
    return xs[.!is_dummy_mask], ys[.!is_dummy_mask] 
end


function order_layers!(graph, layer2nodes)
    m = Model(Cbc.Optimizer)
    #set_silent(m)

    T = JuMP.Containers.DenseAxisArray{VariableRef,1,Tuple{Vector{Int64}},Tuple{Dict{Int64,Int64}}}
    node_is_before = Vector{T}(undef, nv(graph))
    befores = map(enumerate(layer2nodes)) do (layer, nodes)
        before = @variable(m, [nodes, nodes], Bin, base_name="befores_$layer")
        for n1 in nodes
            node_is_before[n1] = before[n1, :]
            for n2 in nodes
                # can't have n1<n2 and n2<n1
                @constraint(m, before[n1, n2] + before[n2, n1] <= 1)
            end
        end
    end


    function crossings(src_layer)
        total = AffExpr(0)
        for src1 in src_layer, src2 in src_layer
            for dst1 in outneighbors(graph, src1), dst2 in outneighbors(graph, src2)
                # Can't cross if share end-point 
                (src1 === src2 || dst1 === dst2) && continue
                
                # two edges cross if the src1 is before scr2; but dst1 is after dest2
                # node_is_before[src1][src2] + node_is_before[dst2][dst1]  - 1
                add_to_expression!(total, node_is_before[src1][src2])
                add_to_expression!(total, node_is_before[dst2][dst1])
            end
        end
        return total
    end

    @objective(m, Min, sum(crossings, layer2nodes))
    optimize!(m)
    @show termination_status(m)

    # Cunning trick: we need to go from the `before` matrix to an actual order list
    # we can do this by sorting when having `lessthan` read from the `before` matrix
    is_before_func(n1, n2) = Bool(value(node_is_before[n1][n2]))
    for layer in layer2nodes
        shuffle!(layer)
        sort!(layer; lt=is_before_func)
    end
end

function assign_coordinates(graph, layer2nodes)
    xs = Vector{Float64}(undef, nv(graph))
    ys = Vector{Float64}(undef, nv(graph))
    for (xi, layer) in enumerate(layer2nodes)
        for (yi, node) in enumerate(layer)
            xs[node] = xi
            ys[node] = yi - length(layer)/2
        end
    end
    return xs, ys
end